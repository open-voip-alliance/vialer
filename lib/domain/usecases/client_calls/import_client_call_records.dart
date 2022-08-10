import 'package:dartx/dartx.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/data/latest.dart';

import '../../../app/util/loggable.dart';
import '../../entities/setting.dart';
import '../../repositories/database/client_calls.dart';
import '../../repositories/local_client_calls.dart';
import '../../repositories/remote_client_calls.dart';
import '../../repositories/services/voipgrid.dart';
import '../get_setting.dart';
import 'create_client_calls_isolate_request.dart';
import 'import_historic_client_call_records.dart';
import 'import_new_client_calls.dart';
import 'purge_local_call_records.dart';

/// This is a generic use case that enables you to import client calls between
/// any date range.
///
/// You should use [ImportHistoricClientCallRecordsUseCase]
/// or [ImportNewClientCallRecordsUseCase] in almost all situations.
class ImportClientCallsUseCase with Loggable {
  final _purgeLocalCallRecords = PurgeLocalCallRecords();
  late final _getClientCallSetting =
      GetSettingUseCase<ShowClientCallsSetting>();
  final _createClientCallsIsolateRequest =
      CreateClientCallsIsolateRequestUseCase();

  Future<bool> get _shouldImport async =>
      _getClientCallSetting().then((setting) => setting.value);

  Future<void> call({
    required DateTime from,
    required DateTime to,
  }) async {
    if (!await _shouldImport) {
      logger.info(
        'Not importing client calls as [ShowClientCallsSetting] is disabled.',
      );
      return;
    }

    final dateRangesToQuery = _createDateRangesToQuery(
      from: from.toUtc(),
      to: to.toUtc(),
    );

    // This is a heavy task so we are starting it in a separate isolate.
    await compute(
      _performImport,
      await _createClientCallsIsolateRequest(
        dateRangesToQuery: dateRangesToQuery,
      ),
    ).catchError(_handleError);
  }

  /// Iterates through the date range given and creates a map of from and to
  /// dates of each month that will be queried.
  Map<DateTime, DateTime> _createDateRangesToQuery({
    required DateTime from,
    required DateTime to,
  }) {
    if (from.isAtSameMonthAs(to)) {
      return {from: to};
    }

    final monthsToQuery = {
      from.firstDayOfMonth: from.lastDayOfMonth,
    };

    var newDate = from.addMonth();

    while (!newDate.isAtSameMonthAs(to)) {
      monthsToQuery[newDate.firstDayOfMonth] = newDate.endOfMonth;
      newDate = newDate.addMonth();
    }

    monthsToQuery[to.firstDayOfMonth] = to;

    return monthsToQuery;
  }

  /// Iterates through a list of phone account ids and fetches and imports
  /// any that are missing from our local database.

  /// It's import that if the user ever loses permissions that we wipe the
  /// local call records so they are no longer stored on the phone.
  ///
  /// If we detect an error from the [RemoteClientCallsRepository] that
  /// indicates this we will trigger a purge of the local database.
  void _handleError(dynamic error) {
    if (error is UserLacksCallRecordsPermission ||
        error is UserWasUnauthorized) {
      _purgeLocalCallRecords(
        reason: error! is UserLacksCallRecordsPermission
            ? PurgeReason.permissionFailed
            : PurgeReason.unauthorized,
      );
      return;
    }

    if (error is Exception) {
      throw error;
    }
  }
}

extension on DateTime {
  DateTime addMonth({int amount = 1}) => DateTime(
        year,
        month + amount,
        day,
        hour,
        minute,
        second,
      );

  DateTime get endOfMonth => DateTime(
        lastDayOfMonth.year,
        lastDayOfMonth.month,
        lastDayOfMonth.day,
        23,
        59,
        59,
        999,
      );
}

/// This function is to be performed on an isolate, it must create all the
/// necessary dependencies for the [RemoteClientCallsRepository] and
/// [LocalClientCallsRepository] manually.
Future<void> _performImport(ClientCallsIsolateRequest request) async {
  initializeTimeZones();

  final remoteClientCalls = RemoteClientCallsRepository(
    VoipgridService.createInIsolate(
      user: request.user,
      baseUrl: request.voipgridApiBaseUrl,
    ),
  );

  final localClientCalls = LocalClientCallsRepository(
    VialerDatabase.createInIsolate(
      request.databasePath,
    ),
  );

  for (final range in request.dateRangesToQuery.entries) {
    final batches = remoteClientCalls.fetchRecordsForDatabaseBetween(
      from: range.key,
      to: range.value,
      isUserPhoneAccount: request.userPhoneAccountIds.contains,
    );

    await for (final batch in batches) {
      await localClientCalls.storeCallRecords(batch);
    }
  }

  await _importPhoneAccountsIfNecessary(
    localClientCalls,
    remoteClientCalls,
    await localClientCalls.findUnfetchedPhoneAccountIds(),
  );
}

Future<void> _importPhoneAccountsIfNecessary(
  LocalClientCallsRepository localClientCalls,
  RemoteClientCallsRepository remoteClientCalls,
  List<int?> accountIds,
) async {
  final ids = accountIds.filterNotNull().distinct();

  for (final id in ids) {
    if (await localClientCalls.isPhoneAccountInDatabase(id)) {
      return;
    }

    await remoteClientCalls
        .fetchPhoneAccount(id)
        .then(localClientCalls.storePhoneAccount);
  }
}

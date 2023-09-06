import 'package:dartx/dartx.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/data/latest.dart';
import 'package:vialer/domain/user/user.dart';

import '../../../../app/util/loggable.dart';
import '../../user/get_logged_in_user.dart';
import '../../user/settings/app_setting.dart';
import '../../voipgrid/voipgrid_service.dart';
import 'create_client_calls_isolate_request.dart';
import 'database/client_calls.dart';
import 'import_historic_client_call_records.dart';
import 'import_new_client_calls.dart';
import 'local_client_calls.dart';
import 'month_splitter.dart';
import 'remote_client_calls.dart';

/// This is a generic use case that enables you to import client calls between
/// any date range.
///
/// You should use [ImportHistoricClientCallRecordsUseCase]
/// or [ImportNewClientCallRecordsUseCase] in almost all situations.
class ImportClientCallsUseCase with Loggable {
  late final _getUser = GetLoggedInUserUseCase();
  final _createClientCallsIsolateRequest =
      CreateClientCallsIsolateRequestUseCase();
  late final _monthSplitter = MonthSplitter();

  static var _isIsolateRunning = false;

  bool get _shouldImport => _getUser().settings.get(AppSetting.showClientCalls);

  Future<void> call({
    required DateTime from,
    required DateTime to,
  }) async {
    if (!_shouldImport) {
      logger.info(
        'Not importing client calls as '
        '[AppSetting.showClientCalls] is disabled.',
      );
      return;
    }

    final dateRangesToQuery = _monthSplitter.split(
      from: from.toUtc(),
      to: to.toUtc(),
    );

    final request = await _createClientCallsIsolateRequest(
      dateRangesToQuery: dateRangesToQuery,
    );

    if (_isIsolateRunning) {
      logger.info('Not spawning isolate as one is already running.');
      return;
    }

    _isIsolateRunning = true;

    await compute(
      _performImport,
      request,
    ).onError((error, stackTrace) {
      _isIsolateRunning = false;
      logger.warning('Client calls import isolate exited with error: $error');
    }).whenComplete(() {
      _isIsolateRunning = false;
      logger.info('Client calls import isolate has completed');
    });
  }
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
    ClientCallsDatabase.createInIsolate(
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

/// Iterates through a list of phone account ids and fetches and imports
/// any that are missing from our local database.
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

import 'package:dartx/dartx.dart';

import '../../../app/util/loggable.dart';
import '../../../dependency_locator.dart';
import '../../entities/setting.dart';
import '../../repositories/local_client_calls.dart';
import '../../repositories/remote_client_calls.dart';
import '../get_latest_availability.dart';
import '../get_setting.dart';
import 'import_historic_client_call_records.dart';
import 'import_new_client_calls.dart';
import 'purge_local_call_records.dart';

/// This is a generic use case that enables you to import client calls between
/// any date range.
///
/// You should use [ImportHistoricClientCallRecordsUseCase]
/// or [ImportNewClientCallRecordsUseCase] in almost all situations.
class ImportClientCallsUseCase with Loggable {
  final _localClientCalls = dependencyLocator<LocalClientCallsRepository>();
  final _remoteClientCalls = dependencyLocator<RemoteClientCallsRepository>();
  final _purgeLocalCallRecords = PurgeLocalCallRecords();
  late final _getClientCallSetting =
      GetSettingUseCase<ShowClientCallsSetting>();
  late final _getLatestUserAvailability = GetLatestAvailabilityUseCase();

  Future<bool> get _shouldImport async =>
      _getClientCallSetting().then((setting) => setting.value);

  Future<List<int>> get _usersPhoneAccounts async =>
      _getLatestUserAvailability().then(
        (availability) =>
            availability?.phoneAccounts
                .map((phoneAccount) => phoneAccount.accountId)
                .toList() ??
            [],
      );

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

    _createDateRangesToQuery(
      from: from.toUtc(),
      to: to.toUtc(),
    ).forEach(await _import);
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

  Future<void> _import(DateTime from, DateTime to) async {
    final usersPhoneAccounts = await _usersPhoneAccounts;

    _remoteClientCalls
        .fetchRecordsForDatabaseBetween(
          from: from,
          to: to,
          isUserPhoneAccount: usersPhoneAccounts.contains,
        )
        .listen(
          _localClientCalls.storeCallRecords,
          onDone: () => _localClientCalls
              .findUnfetchedPhoneAccountIds()
              .then(_importPhoneAccountsIfNecessary),
          onError: _handleError,
        );
  }

  /// Iterates through a list of phone account ids and fetches and imports
  /// any that are missing from our local database.
  Future<void> _importPhoneAccountsIfNecessary(List<int?> accountIds) async {
    final ids = accountIds.filterNotNull().distinct();

    for (final id in ids) {
      if (await _localClientCalls.isPhoneAccountInDatabase(id)) {
        return;
      }

      await _remoteClientCalls
          .fetchPhoneAccount(id)
          .then(_localClientCalls.storePhoneAccount);
    }
  }

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

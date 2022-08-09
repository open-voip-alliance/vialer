import 'package:dartx/dartx.dart';
import 'package:drift/drift.dart';

import '../../app/util/loggable.dart';
import '../../dependency_locator.dart';
import '../entities/call_record.dart';
import '../use_case.dart';
import 'database/client_calls.dart';
import 'mappers/client_call_record.dart';

class LocalClientCallsRepository extends UseCase with Loggable {
  final _db = dependencyLocator<VialerDatabase>();

  /// The amount of time before we consider a phone account stale and will
  /// refresh it.
  static const _phoneAccountLifetime = Duration(days: 1);

  Future<ClientCallDatabaseRecord?> get mostRecent async =>
      (_db.select(_db.clientCalls)
            ..orderBy(
              [
                (row) => OrderingTerm(
                      expression: row.date,
                      mode: OrderingMode.desc,
                    ),
              ],
            )
            ..limit(1))
          .getSingleOrNull();

  Future<int> deleteAll() async => Future.wait([
        _db.delete(_db.colleaguePhoneAccounts).go(),
        _db.delete(_db.clientCalls).go(),
      ]).then((value) => value.sum());

  /// Checks to see if we have a phone account for the given id in the database
  /// and if we do, that it is within the [_phoneAccountLifetime].
  Future<bool> isPhoneAccountInDatabase(int phoneAccountId) =>
      (_db.select(_db.colleaguePhoneAccounts)
            ..where((tbl) => tbl.id.equals(phoneAccountId)))
          .getSingleOrNull()
          .then(
            (result) =>
                result != null &&
                result.fetchedAt.isAfter(
                  DateTime.now().subtract(_phoneAccountLifetime),
                ),
          );

  Future<List<int?>> findUnfetchedPhoneAccountIds() async =>
      _db.callRecordsWithUnfetchedPhoneAccounts().get();

  Future<void> storeCallRecords(List<ClientCallsCompanion> records) =>
      _db.batch(
        (batch) => batch.insertAllOnConflictUpdate(_db.clientCalls, records),
      );

  Future<void> storePhoneAccount(
    ColleaguePhoneAccountsCompanion? phoneAccount,
  ) async {
    if (phoneAccount != null) {
      await _db.colleaguePhoneAccounts.insertOnConflictUpdate(phoneAccount);
    }
  }

  Future<List<CallRecord>> getCalls({
    int page = 1,
    required int perPage,
    required bool onlyMissedCalls,
  }) {
    final sourceAccountTable = _db.alias(
      _db.colleaguePhoneAccounts,
      's',
    );
    final destinationAccountTable = _db.alias(
      _db.colleaguePhoneAccounts,
      'd',
    );

    final query = _db.select(_db.clientCalls).join(
      [
        leftOuterJoin(
          sourceAccountTable,
          sourceAccountTable.id.equalsExp(_db.clientCalls.sourceAccountId),
        ),
        leftOuterJoin(
          destinationAccountTable,
          destinationAccountTable.id
              .equalsExp(_db.clientCalls.destinationAccountId),
        ),
      ],
    )
      ..orderBy([OrderingTerm.desc(_db.clientCalls.date)])
      ..limit(perPage, offset: (page - 1) * perPage);

    return query
        .map((row) => row.readTable(_db.clientCalls).toCallRecord(
              row.readTableOrNull(destinationAccountTable),
              row.readTableOrNull(sourceAccountTable),
            ))
        .get();
  }
}

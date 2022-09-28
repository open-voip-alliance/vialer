import 'package:dartx/dartx.dart';
import 'package:drift/drift.dart';
import 'package:rxdart/rxdart.dart';
import 'package:watcher/watcher.dart';

import '../../app/util/loggable.dart';
import '../entities/call_record.dart';
import '../entities/client_call_record.dart';
import 'database/client_calls.dart';
import 'mappers/client_call_record.dart';

class LocalClientCallsRepository with Loggable {
  final ClientCallsDatabase db;

  LocalClientCallsRepository(this.db);

  /// The amount of time before we consider a phone account stale and will
  /// refresh it.
  static const _phoneAccountLifetime = Duration(days: 1);

  Future<ClientCallDatabaseRecord?> get mostRecent async =>
      (db.select(db.clientCalls)
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
        db.delete(db.colleaguePhoneAccounts).go(),
        db.delete(db.clientCalls).go(),
      ]).then((value) => value.sum());

  /// Checks to see if we have a phone account for the given id in the database
  /// and if we do, that it is within the [_phoneAccountLifetime].
  Future<bool> isPhoneAccountInDatabase(int phoneAccountId) =>
      (db.select(db.colleaguePhoneAccounts)
            ..where((tbl) => tbl.id.equals(phoneAccountId)))
          .getSingleOrNull()
          .then(
            (result) =>
                result != null &&
                result.fetchedAt.isAfter(
                  DateTime.now().subtract(_phoneAccountLifetime),
                ),
          );

  Future<List<int?>> findUnfetchedPhoneAccountIds() async {
    final unfetchedDestinationPhoneAccounts =
        await db.callRecordsWithUnfetchedDestinationAccounts().get();
    final unfetchedSourcePhoneAccounts =
        await db.callRecordsWithUnfetchedSourceAccounts().get();

    return (unfetchedDestinationPhoneAccounts + unfetchedSourcePhoneAccounts)
        .distinct()
        .toList();
  }

  Future<void> storeCallRecords(List<ClientCallsCompanion> records) => db.batch(
        (batch) => batch.insertAllOnConflictUpdate(db.clientCalls, records),
      );

  Future<void> storePhoneAccount(
    ColleaguePhoneAccountsCompanion? phoneAccount,
  ) async {
    if (phoneAccount != null) {
      await db.colleaguePhoneAccounts.insertOnConflictUpdate(phoneAccount);
    }
  }

  Future<List<ClientCallRecord>> getCalls({
    int page = 1,
    required int perPage,
    required bool onlyMissedCalls,
  }) {
    final sourceAccountTable = db.alias(
      db.colleaguePhoneAccounts,
      's',
    );
    final destinationAccountTable = db.alias(
      db.colleaguePhoneAccounts,
      'd',
    );

    final query = db.select(db.clientCalls).join(
      [
        leftOuterJoin(
          sourceAccountTable,
          sourceAccountTable.id.equalsExp(db.clientCalls.sourceAccountId),
        ),
        leftOuterJoin(
          destinationAccountTable,
          destinationAccountTable.id
              .equalsExp(db.clientCalls.destinationAccountId),
        ),
      ],
    )
      ..orderBy(
        [
          OrderingTerm.desc(db.clientCalls.date),
          // We order by the id too so we guarantee a static sort order even
          // for records with the same date.
          OrderingTerm.desc(db.clientCalls.id),
        ],
      )
      ..limit(perPage, offset: (page - 1) * perPage);

    if (onlyMissedCalls) {
      query
        ..where(db.clientCalls.answered.equals(false))
        ..where(
          db.clientCalls.direction.equals(
            db.clientCalls.direction.converter.mapToSql(Direction.inbound),
          ),
        );
    }

    return query
        .map((row) => row.readTable(db.clientCalls).toCallRecord(
              row.readTableOrNull(destinationAccountTable),
              row.readTableOrNull(sourceAccountTable),
            ))
        .get();
  }

  Future<Stream> watch() async {
    final file = await ClientCallsDatabase.databaseFile;

    return FileWatcher(file.path)
        .events
        .debounceTime(const Duration(seconds: 1));
  }
}

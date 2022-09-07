import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../entities/call_record.dart';

part 'client_calls.g.dart';

@DataClassName('ClientCallDatabaseRecord')
class ClientCalls extends Table {
  IntColumn get id => integer()();
  IntColumn get callType => intEnum<CallType>()();
  IntColumn get direction => intEnum<Direction>()();
  BoolColumn get answered => boolean()();
  IntColumn get duration => integer()();
  DateTimeColumn get date => dateTime()();
  TextColumn get sourceNumber => text()();
  IntColumn get sourceAccountId => integer().nullable()();
  TextColumn get destinationNumber => text()();
  TextColumn get dialedNumber => text()();
  IntColumn get destinationAccountId => integer().nullable()();
  TextColumn get callerNumber => text()();
  TextColumn get callerId => text()();
  TextColumn get originalCallerId => text()();
  BoolColumn get isSourceAccountLoggedInUser => boolean()();
  BoolColumn get isDestinationAccountLoggedInUser => boolean()();

  @override
  Set<Column> get primaryKey => {id};
}

class ColleaguePhoneAccounts extends Table {
  IntColumn get id => integer()();
  TextColumn get callerIdName => text()();
  TextColumn get country => text()();
  TextColumn get description => text()();
  TextColumn get internalNumber => text()();
  DateTimeColumn get fetchedAt => dateTime()();
  IntColumn get type => intEnum<CallerType>()();

  @override
  Set<Column> get primaryKey => {id};
}

class ClientCallWithColleaguePhoneAccount {
  final ClientCallDatabaseRecord clientCall;
  final ColleaguePhoneAccount colleaguePhoneAccount;

  ClientCallWithColleaguePhoneAccount(
    this.clientCall,
    this.colleaguePhoneAccount,
  );
}

@DriftDatabase(
  tables: [ClientCalls, ColleaguePhoneAccounts],
  include: {'queries.drift'},
)
class VialerDatabase extends _$VialerDatabase {
  VialerDatabase() : super(_openConnection());

  VialerDatabase.createInIsolate(String path)
      : super(_openConnectionForIsolate(path));

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    return NativeDatabase(await getDatabaseDirectory());
  });
}

LazyDatabase _openConnectionForIsolate(String path) {
  return LazyDatabase(() async {
    return NativeDatabase(File(path));
  });
}

Future<File> getDatabaseDirectory() async {
  final dbFolder = await getApplicationDocumentsDirectory();
  return File(p.join(dbFolder.path, 'db.sqlite'));
}

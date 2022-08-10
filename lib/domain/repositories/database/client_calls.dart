import 'dart:convert';
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
  BoolColumn get answeredElsewhere => boolean()();
  IntColumn get duration => integer()();
  DateTimeColumn get date => dateTime()();
  TextColumn get caller => text().map(const CallPartyConverter())();
  TextColumn get destination => text().map(const CallPartyConverter())();
  IntColumn get destinationAccountId => integer().nullable()();
  IntColumn get sourceAccountId => integer().nullable()();

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

class CallPartyConverter extends TypeConverter<CallParty, String>
    with JsonTypeConverter<CallParty, String> {
  const CallPartyConverter();
  @override
  CallParty? mapToDart(String? fromDb) {
    if (fromDb == null) {
      return null;
    }
    return CallParty.fromJson(json.decode(fromDb) as Map<String, dynamic>);
  }

  @override
  String? mapToSql(CallParty? value) {
    if (value == null) {
      return null;
    }

    return json.encode(value.toJson());
  }
}

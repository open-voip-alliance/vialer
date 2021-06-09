import 'dart:io';

import 'package:moor/ffi.dart';
import 'package:moor/moor.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../entities/call_record.dart';

part 'database.g.dart';

// !!! IMPORTANT !!!
// Eventhough we currently are not using this old app users might still
// have the old version of this database hanging around. For backwards
// compatibility we keep this file around untill we need a version 2 of the
// schema so we don't forget to migrate or run into wierd issues opening
// existing sqlite database we forgotten ever existed.

@DataClassName('CallRecord')
class Calls extends Table {
  IntColumn get id => integer()();

  DateTimeColumn get date => dateTime()();

  IntColumn get duration => integer().map(DurationConverter())();

  TextColumn get callerNumber => text()();

  TextColumn get sourceNumber => text()();

  TextColumn get callerId => text()();

  TextColumn get originalCallerId => text()();

  TextColumn get destinationNumber => text()();

  IntColumn get direction => integer().map(DirectionConverter())();
}

class DirectionConverter extends TypeConverter<Direction, int> {
  @override
  Direction? mapToDart(int? fromDb) =>
      fromDb != null ? Direction.values[fromDb] : null;

  @override
  int? mapToSql(Direction? value) => value?.index;
}

class DurationConverter extends TypeConverter<Duration, int> {
  @override
  Duration? mapToDart(int? fromDb) =>
      fromDb != null ? Duration(seconds: fromDb) : null;

  @override
  int? mapToSql(Duration? value) => value?.inSeconds;
}

@UseMoor(tables: [Calls])
class Database extends _$Database {
  static LazyDatabase _open() {
    return LazyDatabase(() async {
      final dbDir = await getApplicationDocumentsDirectory();
      final file = File(path.join(dbDir.path, 'db.sqlite'));
      return VmDatabase(file);
    });
  }

  Database() : super(_open());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) {
          return m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // In anticipation of introducing caching again for call records
          // we probably need to nuke the existing database and recreate it with
          // a new schema to facilitate the new data structures. Here's a way
          // to do that.
          // if (from == 1) {
          //   await m.drop(calls);
          //   await m.createAll();
          // }
        },
      );
}

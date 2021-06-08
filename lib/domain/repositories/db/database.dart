import 'dart:io';

import 'package:moor/ffi.dart';
import 'package:moor/moor.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../../data/mappers/call_record.dart';
import '../../entities/call_record.dart';

part 'database.g.dart';

@DataClassName('DbCallRecord')
class Calls extends Table {
  TextColumn get id => text()();
  IntColumn get direction => integer().map(DirectionConverter())();
  BoolColumn get answered => boolean()();
  BoolColumn get answeredElsewhere => boolean()();
  IntColumn get duration => integer().map(DurationConverter())();
  DateTimeColumn get date => dateTime()();
  TextColumn get callerName => text().nullable()();
  TextColumn get callerNumber => text()();
  TextColumn get destinationName => text().nullable()();
  TextColumn get destinationNumber => text()();
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
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) {
          return m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from == 1) {
            // Very big change so just drop and recreate.
            await m.drop(calls);
            await m.createAll();
          }
        },
      );

  Future<List<CallRecord>> getCalls({
    required DateTime from,
    required DateTime to,
  }) async {
    return (select(calls)
          ..where((c) => c.date.isBetweenValues(from, to))
          ..orderBy(
            [(c) => OrderingTerm.desc(c.date)],
          ))
        .map((r) => r.toCallRecord())
        .get();
  }

  Future<CallRecord> getMostRecentCall() async {
    return (select(calls)
          ..orderBy([(c) => OrderingTerm.desc(c.date)])
          ..limit(1))
        .map((c) => c.toCallRecord())
        .getSingle();
  }

  Future<void> insertCalls(List<CallRecord> values) async {
    await batch((batch) {
      batch.insertAll(
        calls,
        values.map((c) => c.toDbCallRecord()).toList(),
        mode: InsertMode.insertOrIgnore,
      );
    });
  }
}

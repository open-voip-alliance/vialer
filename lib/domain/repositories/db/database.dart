import 'dart:io';

import 'package:moor/moor.dart';
import 'package:moor_ffi/moor_ffi.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../../domain/entities/call.dart';

part 'database.g.dart';

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
  Direction mapToDart(int fromDb) => Direction.values[fromDb];

  @override
  int mapToSql(Direction value) => value.index;
}

class DurationConverter extends TypeConverter<Duration, int> {
  @override
  Duration mapToDart(int fromDb) => Duration(seconds: fromDb);

  @override
  int mapToSql(Duration value) => value.inSeconds;
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

  Future<List<Call>> getCalls({
    @required DateTime from,
    @required DateTime to,
  }) async {
    return (select(calls)
          ..where((c) => c.date.isBetweenValues(from, to))
          ..orderBy(
            [(c) => OrderingTerm.desc(c.date)],
          ))
        .map((r) => r.toCall())
        .get();
  }

  Future<Call> getMostRecentCall() async {
    return (select(calls)
          ..orderBy([(c) => OrderingTerm.desc(c.date)])
          ..limit(1))
        .map((c) => c.toCall())
        .getSingle();
  }

  Future<void> insertCalls(List<Call> values) async {
    await batch((batch) {
      batch.insertAll(
        calls,
        values.map((c) => c.toRecord()).toList(),
        mode: InsertMode.insertOrIgnore,
      );
    });
  }
}

extension on CallRecord {
  Call toCall() {
    return Call(
      id: id,
      // Because dates in Moor are stored as Unix times and they don't
      // specify isUtc true in the DateTime Unix time constructor,
      // the r.date is local and needs to be converted to UTC time.
      date: date.toUtc(),
      duration: duration,
      callerNumber: callerNumber,
      sourceNumber: sourceNumber,
      callerId: callerId,
      originalCallerId: originalCallerId,
      destinationNumber: destinationNumber,
      direction: direction,
    );
  }
}

extension on Call {
  CallRecord toRecord() {
    return CallRecord(
      id: id,
      date: date,
      duration: duration,
      callerNumber: callerNumber,
      sourceNumber: sourceNumber,
      callerId: callerId,
      originalCallerId: originalCallerId,
      destinationNumber: destinationNumber,
      direction: direction,
    );
  }
}

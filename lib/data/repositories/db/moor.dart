import 'dart:io';

import 'package:moor/moor.dart';
import 'package:moor_ffi/moor_ffi.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../../domain/entities/call.dart';

part 'moor.g.dart';

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
        .map(
          (r) => Call(
            id: r.id,
            // Because dates in Moor are stored as Unix times and they don't
            // specify isUtc true in the DateTime Unix time constructor,
            // the r.date is local and needs to be converted to UTC time.
            date: r.date.toUtc(),
            duration: r.duration,
            callerNumber: r.callerNumber,
            sourceNumber: r.sourceNumber,
            callerId: r.callerId,
            originalCallerId: r.originalCallerId,
            destinationNumber: r.destinationNumber,
            direction: r.direction,
          ),
        )
        .get();
  }

  Future<void> insertCalls(List<Call> entries) async {
    await batch((batch) {
      batch.insertAll(
          calls,
          entries
              .map(
                (e) => CallRecord(
                  id: e.id,
                  date: e.date,
                  duration: e.duration,
                  callerNumber: e.callerNumber,
                  sourceNumber: e.sourceNumber,
                  callerId: e.callerId,
                  originalCallerId: e.originalCallerId,
                  destinationNumber: e.destinationNumber,
                  direction: e.direction,
                ),
              )
              .toList());
    });
  }
}

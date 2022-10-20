import 'package:drift/drift.dart';

import '../../util.dart';

part 'log_events.g.dart';

class LogEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get logTime => dateTime()();
  IntColumn get level => intEnum<LogLevel>()();
  TextColumn get message => text()();
}

@DriftDatabase(tables: [LogEvents])
class LoggingDatabase extends _$LoggingDatabase {
  static String get dbFilename => 'logging_db.sqlite';

  LoggingDatabase() : super(DatabaseUtils.openConnection(dbFilename));

  LoggingDatabase.createInIsolate(String path)
      : super(DatabaseUtils.openConnectionForIsolate(path));

  @override
  int get schemaVersion => 1;
}

enum LogLevel {
  verbose,
  debug,
  info,
  warning,
  error,
}

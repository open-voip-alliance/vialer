import 'package:drift/drift.dart';

import '../../database_util.dart';

part 'log_events.g.dart';

class LogEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get logTime => dateTime()();
  IntColumn get level => intEnum<LogLevel>()();
  TextColumn get uuid => text()();
  TextColumn get name => text()();
  TextColumn get message => text()();
}

@DriftDatabase(tables: [LogEvents])
class LoggingDatabase extends _$LoggingDatabase {
  static String get dbFilename => 'logging_db.sqlite';

  LoggingDatabase() : super(openDatabaseConnection(dbFilename));

  LoggingDatabase.createInIsolate(String path)
      : super(openDatabaseConnectionInIsolate(path));

  // TODO: TEMPORARY: We must call something on the database so that it's
  // created. Can be removed once we log things in Dart.
  void open() {
    select(logEvents).get();
  }

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

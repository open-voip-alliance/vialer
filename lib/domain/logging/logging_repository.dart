import 'dart:async';
import 'dart:developer';

import 'package:drift/drift.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:watcher/watcher.dart';

import '../../app/util/pigeon.dart';
import '../database_util.dart';
import '../user/user.dart';
import 'database/log_events.dart';

class LoggingRepository {
  final _nativeLogging = NativeLogging();
  final LoggingDatabase _db;

  LoggingRepository(this._db);

  String _logStringForConsole(
    LogRecord record, {
    required String userIdentifier,
    required bool remote,
  }) =>
      '[${record.time}] ${record.level.name} '
      '$userIdentifier${record.loggerName}: ${record.message}';

  Future<void> _storeLogEvent(LogEventsCompanion logEvent) async {
    await _db.logEvents.insertOne(logEvent);
  }

  Future<void> enableConsoleLogging({
    String userIdentifier = '',
    void Function(String log)? onLog,
  }) async {
    Logger.root.onRecord.listen((record) {
      final logString = _logStringForConsole(
        record,
        userIdentifier: userIdentifier,
        remote: false,
      );
      onLog?.call(logString);

      log(logString);
    });
  }

  Future<void> enableDatabaseLogging({
    String userIdentifier = '',
  }) async {
    Logger.root.onRecord.listen((record) {
      if (record.level != Level.OFF) {
        _storeLogEvent(LogEventsCompanion(
          logTime: Value(record.time.millisecondsSinceEpoch),
          level: Value(record.level.toLogLevel()),
          name: Value(record.loggerName),
          message: Value(record.message),
        ));
      }
    });
  }

  Future<void> enableNativeConsoleLogging() =>
      _nativeLogging.startNativeConsoleLogging();

  Future<void> disableNativeConsoleLogging() =>
      _nativeLogging.stopNativeConsoleLogging();

  Future<List<LogEvent>> getOldestLogs({
    required int amount,
  }) =>
      (_db.select(_db.logEvents)
            ..orderBy([
              (t) => OrderingTerm(expression: _db.logEvents.logTime),
            ])
            ..limit(amount))
          .get();

  Future<void> deleteLogs(List<int> ids) async {
    await (_db.delete(_db.logEvents)..where((t) => t.id.isIn(ids))).go();
  }

  Future<bool> hasLogs() => (_db.select(_db.logEvents)..limit(1))
      .getSingleOrNull()
      .then((value) => value != null);

  Future<Stream> watch() async {
    final file = await getDatabaseFile(LoggingDatabase.dbFilename);

    return FileWatcher(file.path)
        .events
        .debounceTime(const Duration(seconds: 5));
  }
}

extension Logging on User {
  String get loggingIdentifier => uuid;
}

extension LogLevelMapper on Level {
  LogLevel toLogLevel() {
    if (const [
      Level.ALL,
      Level.FINEST,
      Level.FINER,
      Level.FINE,
      Level.INFO,
    ].contains(this)) {
      return LogLevel.info;
    } else if (this == Level.CONFIG) {
      return LogLevel.debug;
    } else if (this == Level.WARNING) {
      return LogLevel.warning;
    } else {
      // Level.SEVERE || Level.SHOUT
      return LogLevel.error;
    }
  }
}

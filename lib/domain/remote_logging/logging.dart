import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:logging/logging.dart';

import '../../app/util/pigeon.dart';
import '../user/user.dart';
import 'database/log_events.dart';

class LoggingRepository {
  /// A map that will be used to anonymize the logs in both dart and the native
  /// loggers.
  ///
  /// The key of the map must be a regex string, and the value should be the
  /// corresponding replacement. Every log entry must replace any values
  /// regex matching the key with the value.
  ///
  /// This is to ensure we do not upload any user-identifiable data to our
  /// logging service.
  static final _anonymizationRules = {
    // Source: https://stackoverflow.com/a/6967885
    r'\+(9[976]\d|8[987530]\d|6[987]\d|5[90]\d|42\d|3[875]\d|'
            r'2[98654321]\d|9[8543210]|8[6421]|6[6543210]|5[87654321]|'
            r'4[987654310]|3[9643210]|2[70]|7|1)\d{1,14}$':
        '[REDACTED PHONE NUMBER]',

    // Source: https://emailregex.com/
    '(?:[a-z0-9!#\$%&\'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#\$%&\'*+/=?^_`{|}~-]+)*|'
        r'"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b'
        r'\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9]'
        r'(?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)'
        r'\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:'
        r'[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b'
        r'\x0c\x0e-\x7f])+)\])': '[REDACTED EMAIL]',

    'sip:\+?\d+': 'sip:[REDACTED]',
    'To:(.+?)>': 'To: [REDACTED]',
    'From:(.+?)>': 'From: [REDACTED]',
    'Contact:(.+?)>': 'Contact: [REDACTED]',
    'username=(.+?)&': 'username=[REDACTED]',
    'nonce="(.+?)"': 'nonce="[REDACTED]"',
    '"caller_id" = (.+?);': '"caller_id" = [REDACTED];',
    'Digest username="(.+?)"': 'Digest username="[REDACTED]"',
  };

  SecureSocket? _remoteLoggingSocket;

  StreamSubscription? _remoteLogSubscription;

  bool get isLoggingToRemote => _remoteLogSubscription != null;

  bool _isNativelyLoggingToRemote = false;

  bool get isNativelyLoggingToRemote => _isNativelyLoggingToRemote;

  final _nativeRemoteLogging = NativeLogging();

  final LoggingDatabase db;

  LoggingRepository(this.db);

  String _logStringOf(
    LogRecord record, {
    required String userIdentifier,
    required bool remote,
  }) {
    final message =
        remote ? _anonymizationRules.apply(record.message) : record.message;

    return '[${record.time}] ${record.level.name} '
        '$userIdentifier${record.loggerName}: $message';
  }

  Future<void> _storeLogEvent(LogEventsCompanion logEvent) async {
    await db.logEvents.insertOne(logEvent);
  }

  Future<void> enableConsoleLogging({
    String userIdentifier = '',
    void Function(String log)? onLog,
  }) async {
    Logger.root.onRecord.listen((record) {
      final logString = _logStringOf(
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
          logTime: Value(record.time),
          level: Value(record.level.toLogLevel()),
          name: Value(record.loggerName),
          message: Value(record.message),
        ));
      }
    });
  }

  Future<void> sendLogsToRemote(
    String logs, {
    required String token,
  }) async {
    assert(_remoteLoggingSocket != null);

    final savedLogs = logs.split('\n');

    _remoteLoggingSocket!.write(
      savedLogs.map((line) => '$token $line').join('\n'),
    );
  }

  Future<void> disableRemoteLogging() async {
    await _remoteLogSubscription?.cancel();
    _remoteLogSubscription = null;
  }

  Future<void> enableNativeRemoteLogging({
    required String userIdentifier,
    required String token,
  }) async {
    await _nativeRemoteLogging.startNativeRemoteLogging(
      token,
      userIdentifier,
      _anonymizationRules,
    );
    _isNativelyLoggingToRemote = true;
  }

  Future<void> disableNativeRemoteLogging() async {
    await _nativeRemoteLogging.stopNativeRemoteLogging();
    _isNativelyLoggingToRemote = false;
  }

  Future<void> enableNativeConsoleLogging() =>
      _nativeRemoteLogging.startNativeConsoleLogging();

  Future<void> disableNativeConsoleLogging() =>
      _nativeRemoteLogging.stopNativeConsoleLogging();
}

extension Logging on User {
  String get loggingIdentifier => uuid;
}

extension on Map<String, String> {
  String apply(String subject) => entries.fold(
        subject,
        (previousValue, element) => previousValue.replaceAll(
          element.key,
          element.value,
        ),
      );
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
    } else if (this == Level.OFF) {
      return LogLevel.off;
    } else {
      // Level.SEVERE || Level.SHOUT
      return LogLevel.error;
    }
  }
}

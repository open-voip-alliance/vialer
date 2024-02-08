import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';

import '../../../presentation/util/pigeon.dart';
import '../../models/user/user.dart';

@singleton
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
    r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"
        r'"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b'
        r'\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9]'
        r'(?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)'
        r'\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:'
        r'[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b'
        r'\x0c\x0e-\x7f])+)\])': '[REDACTED EMAIL]',

    // ignore: unnecessary_string_escapes
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

  StreamSubscription<LogRecord>? _remoteLogSubscription;

  bool get isLoggingToRemote => _remoteLogSubscription != null;

  bool _isNativelyLoggingToRemote = false;

  bool get isNativelyLoggingToRemote => _isNativelyLoggingToRemote;

  final _nativeRemoteLogging = NativeLogging();

  int _restartRemoteConnectionCount = 0;
  bool _connectedToRemote = false;

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

  Future<void> enableRemoteLogging({
    required String token,
    String userIdentifier = '',
  }) async {
    Future<void> startConnection() async {
      try {
        _remoteLoggingSocket = await SecureSocket.connect(
          'data.logentries.com',
          443,
        );

        unawaited(
          _remoteLoggingSocket!.done.onError(
            (error, stackTrace) {
              // Keep track if we need to restart remote logging if we got
              // disconnected.
              if (error is SocketException) {
                _connectedToRemote = false;
              }
            },
          ),
        );

        _restartRemoteConnectionCount = 0;
        _connectedToRemote = true;
      } on SocketException catch (e) {
        log('Can not connect to Logentries. Reason: $e');

        _restartRemoteConnectionCount++;
        _connectedToRemote = false;
      }
    }

    await startConnection();

    if (token.isNotEmpty) {
      _remoteLogSubscription ??= Logger.root.onRecord.listen((record) async {
        final message = _logStringOf(
          record,
          userIdentifier: userIdentifier,
          remote: true,
        );

        if (!_connectedToRemote && _restartRemoteConnectionCount < 10) {
          await startConnection();

          if (_restartRemoteConnectionCount == 10) {
            log('Can not connect to Logentries, not trying again');
          }
        }

        if (_connectedToRemote) {
          _remoteLoggingSocket!.writeln('$token $message');
        }
      });
    }
  }

  Future<void> sendLogsToRemote(
    String logs, {
    required String token,
  }) async {
    assert(_remoteLoggingSocket != null, 'remoteLoggingSocket is null');

    final savedLogs = logs.split('\n');

    _remoteLoggingSocket!.write(
      savedLogs.map((line) => '$token $line').join('\n'),
    );
  }

  Future<void> disableRemoteLogging() async {
    await _remoteLogSubscription?.cancel();
    _remoteLogSubscription = null;
    await _remoteLoggingSocket?.close();
    _remoteLoggingSocket = null;
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

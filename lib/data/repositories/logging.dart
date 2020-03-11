import 'dart:async';

import 'package:logging/logging.dart';

import '../../domain/entities/setting.dart';

import '../../domain/repositories/logging.dart';
import '../../domain/repositories/auth.dart';
import '../../domain/repositories/storage.dart';
import '../../domain/repositories/setting.dart';

class DataLoggingRepository extends LoggingRepository {
  final AuthRepository _authRepository;
  final StorageRepository _storageRepository;
  final SettingRepository _settingRepository;

  DataLoggingRepository(
    this._authRepository,
    this._storageRepository,
    this._settingRepository,
  );

  StreamSubscription _remoteLogSubscription;

  void _clearLogHistoryOnNewDay() {
    final lastLog = _storageRepository.logs?.split('\n')?.last;
    if (lastLog == null) {
      return;
    }

    final match = RegExp(r'\[(.+)\]').firstMatch(lastLog);
    if (match == null) {
      return;
    }

    final dateTimeString = match.groupCount >= 1 ? match.group(1) : null;
    if (dateTimeString == null) {
      return;
    }

    final date = DateTime.parse(dateTimeString);
    final now = DateTime.now();

    if (date.day != now.day) {
      Logger('$runtimeType').info('Clearing log history');
      _storageRepository.logs = null;
    }
  }

  String _logString(LogRecord record) {
    // Hacky way to silence the Clean Architecture dispose logs
    if (record.message.startsWith('Disposing ')) {
      return null;
    }

    final user = _authRepository.currentUser;
    final uuid = user != null ? '${user.uuid} ' : '';

    return '[${record.time}] ${record.level.name} $uuid${record.loggerName}:'
        ' ${record.message}';
  }

  @override
  Future<void> enableConsoleLogging() async {
    _clearLogHistoryOnNewDay();
    Logger.root.onRecord.listen((record) {
      final logString = _logString(record);
      if (logString != null) {
        _storageRepository.appendLogs(logString);
        print(logString);
      }
    });
  }

  @override
  Future<void> enableRemoteLoggingIfSettingEnabled() async {
    final settings = await _settingRepository.getSettings();
    final setting = settings.whereType<RemoteLoggingSetting>().firstWhere(
          (_) => true,
          orElse: null,
        );

    if (setting?.value == true) {
      await enableRemoteLogging();
    }
  }

  @override
  Future<void> enableRemoteLogging() async {
    _remoteLogSubscription ??= Logger.root.onRecord.listen((record) {
      // Send it somewhere
    });
  }

  @override
  Future<void> disableRemoteLogging() async {
    await _remoteLogSubscription.cancel();
    _remoteLogSubscription = null;
  }
}

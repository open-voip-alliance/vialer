import 'dart:async';

import '../repositories/setting.dart';
import '../repositories/logging.dart';
import '../use_case.dart';

class ResetSettingsUseCase extends FutureUseCase<void> {
  final SettingRepository _settingRepository;
  final LoggingRepository _loggingRepository;

  ResetSettingsUseCase(
    this._settingRepository,
    this._loggingRepository,
  );

  @override
  Future<void> call() async {
    await _settingRepository.resetToDefaults();
    await _loggingRepository.enableRemoteLoggingIfSettingEnabled();
  }
}

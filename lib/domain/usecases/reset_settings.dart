import 'dart:async';

import '../entities/audio_codec.dart';

import '../../dependency_locator.dart';
import '../repositories/setting.dart';
import '../repositories/logging.dart';
import '../entities/setting.dart';
import '../use_case.dart';

class ResetSettingsUseCase extends FutureUseCase<void> {
  final _settingRepository = dependencyLocator<SettingRepository>();
  final _loggingRepository = dependencyLocator<LoggingRepository>();

  @override
  Future<void> call() async {
    await _settingRepository.changeSetting(RemoteLoggingSetting(false));
    await _settingRepository.changeSetting(ShowDialerConfirmPopupSetting(true));
    await _settingRepository.changeSetting(ShowSurveyDialogSetting(true));
    await _settingRepository.changeSetting(
      ShowTroubleshootingSettingsSetting(false),
    );
    await _settingRepository.changeSetting(UseEncryptionSetting(true));
    await _settingRepository.changeSetting(AudioCodecSetting(AudioCodec.opus));
    await _settingRepository.changeSetting(UsePhoneRingtoneSetting(false));

    await _loggingRepository.enableRemoteLoggingIfSettingEnabled();
  }
}

import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../domain/entities/setting.dart';

import '../../../../domain/repositories/storage.dart';
import '../../../../domain/repositories/logging.dart';
import '../../../../domain/repositories/setting.dart';
import '../../../../domain/repositories/build_info.dart';

import '../../../../domain/usecases/get_settings.dart';
import '../../../../domain/usecases/get_build_info.dart';
import '../../../../domain/usecases/change_setting.dart';
import '../../../../domain/usecases/logout.dart';

import '../../../util/debug.dart';

class SettingsPresenter extends Presenter {
  Function settingsOnNext;
  Function buildInfoOnNext;
  Function changeSettingsOnNext;
  Function logoutOnComplete;

  final GetSettingsUseCase _getSettings;
  final GetBuildInfoUseCase _getBuildInfo;
  final ChangeSettingUseCase _changeSetting;
  final LogoutUseCase _logout;

  SettingsPresenter(
    SettingRepository settingRepository,
    BuildInfoRepository buildInfoRepository,
    LoggingRepository loggingRepository,
    StorageRepository storageRepository,
  )   : _getSettings = GetSettingsUseCase(settingRepository),
        _getBuildInfo = GetBuildInfoUseCase(buildInfoRepository),
        _changeSetting = ChangeSettingUseCase(
          settingRepository,
          loggingRepository,
        ),
        _logout = LogoutUseCase(storageRepository);

  void getSettings() {
    _getSettings().then(settingsOnNext);
  }

  void getBuildInfo() {
    _getBuildInfo().then(buildInfoOnNext);
  }

  void changeSetting(Setting setting) {
    if (setting is RemoteLoggingSetting && inDebugMode) {
      return;
    }

    _changeSetting(
      setting: setting,
    ).then((_) => changeSettingsOnNext());
  }

  void logout() {
    _logout().then((_) => logoutOnComplete());
  }

  @override
  void dispose() {}
}

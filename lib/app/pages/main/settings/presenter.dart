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

import '../util/observer.dart';

class SettingsPresenter extends Presenter {
  Function settingsOnNext;
  Function buildInfoOnNext;
  Function changeSettingsOnNext;
  Function logoutOnComplete;

  final GetSettingsUseCase _getSettingsUseCase;
  final GetBuildInfoUseCase _getBuildInfoUseCase;
  final ChangeSettingUseCase _changeSettingUseCase;
  final LogoutUseCase _logoutUseCase;

  SettingsPresenter(
    SettingRepository settingRepository,
    BuildInfoRepository buildInfoRepository,
    LoggingRepository loggingRepository,
    StorageRepository storageRepository,
  )   : _getSettingsUseCase = GetSettingsUseCase(settingRepository),
        _getBuildInfoUseCase = GetBuildInfoUseCase(buildInfoRepository),
        _changeSettingUseCase = ChangeSettingUseCase(
          settingRepository,
          loggingRepository,
        ),
        _logoutUseCase = LogoutUseCase(storageRepository);

  void getSettings() {
    _getSettingsUseCase.execute(Watcher(onNext: settingsOnNext));
  }

  void getBuildInfo() {
    _getBuildInfoUseCase.execute(Watcher(onNext: buildInfoOnNext));
  }

  void changeSetting(Setting setting) {
    if (setting is RemoteLoggingSetting && inDebugMode) {
      return;
    }

    _changeSettingUseCase.execute(
      Watcher(
        onComplete: changeSettingsOnNext,
        onNext: (_) => changeSettingsOnNext,
      ),
      ChangeSettingUseCaseParams(setting),
    );
  }

  void logout() {
    _logoutUseCase.execute(
      Watcher(
        onComplete: logoutOnComplete,
        onNext: (_) => logoutOnComplete,
      ),
    );
  }

  @override
  void dispose() {
    _getSettingsUseCase.dispose();
  }
}

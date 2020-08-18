import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../domain/entities/setting.dart';

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

  final _getSettings = GetSettingsUseCase();
  final _getBuildInfo = GetBuildInfoUseCase();
  final _changeSetting = ChangeSettingUseCase();
  final _logout = LogoutUseCase();

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

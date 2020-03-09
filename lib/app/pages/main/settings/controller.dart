import 'package:flutter/widgets.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../domain/repositories/storage.dart';
import '../../../../domain/repositories/setting.dart';

import '../../../../domain/entities/setting.dart';

import '../../../routes.dart';
import 'presenter.dart';

class SettingsController extends Controller {
  final SettingsPresenter _presenter;

  List<Setting> settings = [];

  SettingsController(
    SettingRepository settingRepository,
    StorageRepository storageRepository,
  ) : _presenter = SettingsPresenter(settingRepository, storageRepository);

  @override
  void initController(GlobalKey<State<StatefulWidget>> key) {
    super.initController(key);

    getSettings();
  }

  void getSettings() => _presenter.getSettings();

  void _onSettingsUpdated(List<Setting> settings) {
    this.settings = settings;

    refreshUI();
  }

  void changeSetting(Setting setting) => _presenter.changeSetting(setting);

  void logout() => _presenter.logout();

  void _logoutOnComplete() {
    Navigator.pushNamedAndRemoveUntil(
      getContext(),
      Routes.onboarding,
      (r) => false,
    );
  }

  @override
  void initListeners() {
    _presenter.settingsOnNext = _onSettingsUpdated;
    _presenter.changeSettingsOnNext = getSettings;
    _presenter.logoutOnComplete = _logoutOnComplete;
  }
}

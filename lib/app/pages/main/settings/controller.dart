import 'package:flutter/widgets.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../domain/repositories/setting.dart';
import '../../../../domain/entities/setting.dart';

import 'presenter.dart';

class SettingsController extends Controller {
  final SettingsPresenter _presenter;

  List<Setting> settings = [];

  SettingsController(SettingRepository settingRepository)
      : _presenter = SettingsPresenter(settingRepository);

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

  @override
  void initListeners() {
    _presenter.settingsOnNext = _onSettingsUpdated;
    _presenter.changeSettingsOnNext = getSettings;
  }
}

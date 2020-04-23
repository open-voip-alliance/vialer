import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../domain/repositories/storage.dart';
import '../../../../domain/repositories/logging.dart';
import '../../../../domain/repositories/setting.dart';

import '../../../../domain/entities/setting.dart';

import '../../../routes.dart';

import '../util/stylized_snack_bar.dart';

import 'presenter.dart';

class SettingsController extends Controller {
  final SettingsPresenter _presenter;

  List<Setting> settings = [];

  SettingsController(
    SettingRepository settingRepository,
    LoggingRepository loggingRepository,
    StorageRepository storageRepository,
  ) : _presenter = SettingsPresenter(
          settingRepository,
          loggingRepository,
          storageRepository,
        );

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

  void changeSetting(Setting setting) {
    logger.info('Set ${setting.runtimeType} to ${setting.value}');
    _presenter.changeSetting(setting);
  }

  Future<void> goToFeedbackPage() async {
    final sent = await Navigator.pushNamed(
          getContext(),
          Routes.feedback,
        ) ??
        false;

    if (sent) {
      showSnackBar(getContext(), text: 'Sent feedback');
    }
  }

  void logout() {
    logger.info('Logging out');
    _presenter.logout();
  }

  void _logoutOnComplete() {
    logger.info('Logged out');
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

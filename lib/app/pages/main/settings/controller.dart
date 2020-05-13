import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../domain/repositories/storage.dart';
import '../../../../domain/repositories/logging.dart';
import '../../../../domain/repositories/setting.dart';
import '../../../../domain/repositories/build_info.dart';

import '../../../../domain/entities/setting.dart';
import '../../../../domain/entities/build_info.dart';

import '../../../routes.dart';

import '../util/stylized_snack_bar.dart';

import '../../../resources/localizations.dart';

import 'presenter.dart';

class SettingsController extends Controller {
  final SettingsPresenter _presenter;

  List<Setting> settings = [];
  BuildInfo buildInfo;

  SettingsController(
    SettingRepository settingRepository,
    BuildInfoRepository buildInfoRepository,
    LoggingRepository loggingRepository,
    StorageRepository storageRepository,
  ) : _presenter = SettingsPresenter(
          settingRepository,
          buildInfoRepository,
          loggingRepository,
          storageRepository,
        );

  @override
  void initController(GlobalKey<State<StatefulWidget>> key) {
    super.initController(key);

    getSettings();
    getBuildInfo();
  }

  void getSettings() => _presenter.getSettings();

  void _onSettingsUpdated(List<Setting> settings) {
    this.settings = settings;

    refreshUI();
  }

  void getBuildInfo() => _presenter.getBuildInfo();

  void _onBuildInfoUpdated(BuildInfo buildInfo) {
    this.buildInfo = buildInfo;

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
      showSnackBar(
        getContext(),
        text: getContext().msg.main.settings.feedback.snackBar,
      );
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
    _presenter.buildInfoOnNext = _onBuildInfoUpdated;
    _presenter.changeSettingsOnNext = getSettings;
    _presenter.logoutOnComplete = _logoutOnComplete;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../domain/entities/call_through_exception.dart';
import '../../../../domain/entities/setting.dart';

import '../../../../domain/repositories/call.dart';
import '../../../../domain/repositories/setting.dart';
import '../../../../domain/repositories/logging.dart';

import '../../../../dependency_locator.dart';
import 'confirm/page.dart';
import 'show_call_through_error_dialog.dart';

mixin Caller on Controller {
  final callRepository = dependencyLocator<CallRepository>();
  final settingRepository = dependencyLocator<SettingRepository>();
  final loggingRepository = dependencyLocator<LoggingRepository>();

  void executeCallUseCase(String destination);

  Future<void> call(String destination) async {
    final shouldShowConfirmPage =
        _settings?.get<ShowDialerConfirmPopupSetting>()?.value ?? true;

    if (shouldShowConfirmPage) {
      logger.info('Going to call through page');

      // Push using the root navigator, the popup should be above everything
      await Navigator.of(getContext(), rootNavigator: true).push(
        ConfirmPageRoute(
          destination: destination,
        ),
      );

      executeGetSettingsUseCase();
    } else {
      logger.info('Starting call');
      executeCallUseCase(destination);
    }
  }

  Future<void> showException(CallThroughException exception) =>
      showCallThroughErrorDialog(getContext(), exception);

  List<Setting> _settings;

  // ignore: use_setters_to_change_properties
  void setSettings(List<Setting> settings) {
    _settings = settings;
  }

  void executeGetSettingsUseCase();
}

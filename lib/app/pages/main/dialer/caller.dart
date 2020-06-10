import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../domain/entities/call_through_exception.dart';
import '../../../../domain/entities/setting.dart';

import '../../../../domain/repositories/call.dart';
import '../../../../domain/repositories/setting.dart';
import '../../../../domain/repositories/logging.dart';

import 'confirm/page.dart';

import 'show_call_through_error_dialog.dart';

mixin Caller on Controller {
  CallRepository get callRepository;

  SettingRepository get settingRepository;

  LoggingRepository get loggingRepository;

  void executeCallUseCase(String destination);

  Future<void> call(String destination) async {
    final shouldShowConfirmPage =
        _settings?.get<ShowDialerConfirmPopupSetting>()?.value ?? true;

    if (shouldShowConfirmPage) {
      logger.info('Start calling: $destination, going to call through page');
      await Navigator.push(
        getContext(),
        ConfirmPageRoute(
          callRepository,
          settingRepository,
          loggingRepository,
          destination: destination,
        ),
      );

      executeGetSettingsUseCase();
    } else {
      logger.info('Calling $destination');
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

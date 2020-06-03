import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../domain/entities/call_through_exception.dart';
import '../../../../domain/entities/setting.dart';

import '../../../../domain/repositories/call.dart';
import '../../../../domain/repositories/setting.dart';
import '../../../../domain/repositories/logging.dart';

import 'confirm/page.dart';

import '../../../resources/localizations.dart';

mixin Caller on Controller {
  CallRepository get callRepository;

  SettingRepository get settingRepository;

  LoggingRepository get loggingRepository;

  void executeCallUseCase(String destination);

  void call(String destination) {
    final shouldShowConfirmPage =
        _settings?.get<ShowDialerConfirmPopupSetting>()?.value ?? true;

    if (shouldShowConfirmPage) {
      logger.info('Start calling: $destination, going to call through page');
      Navigator.push(
        getContext(),
        ConfirmPageRoute(
          callRepository,
          settingRepository,
          loggingRepository,
          destination: destination,
        ),
      );
    } else {
      logger.info('Calling $destination');
      executeCallUseCase(destination);
    }
  }

  Future<void> showException(CallThroughException exception) {
    String message;
    if (exception is InvalidDestinationException) {
      message = getContext().msg.main.callThrough.error.invalidDestination;
    } else {
      message = getContext().msg.main.callThrough.error.unknown;
    }

    return showDialog<void>(
      context: getContext(),
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: Text(context.msg.main.callThrough.error.title),
          content: SingleChildScrollView(
            child: Text(message),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(context.msg.generic.button.ok.toUpperCase()),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  List<Setting> _settings;

  // ignore: use_setters_to_change_properties
  void setSettings(List<Setting> settings) {
    _settings = settings;
  }

  void executeGetSettingsUseCase();
}

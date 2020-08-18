import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../../domain/entities/setting.dart';

import '../../../../../domain/repositories/auth.dart';
import '../../../../../domain/repositories/call.dart';
import '../../../../../domain/repositories/logging.dart';
import '../../../../../domain/repositories/setting.dart';

import '../../../../../domain/usecases/call.dart';
import '../../../../../domain/usecases/change_setting.dart';
import '../../../../../domain/usecases/get_outgoing_cli.dart';
import '../../../../../domain/usecases/get_settings.dart';

class ConfirmPresenter extends Presenter {
  Function callOnComplete;
  Function callOnError;

  Function settingsOnNext;

  Function outgoingCliOnNext;

  final CallUseCase _call;
  final GetSettingsUseCase _getSettings;
  final ChangeSettingUseCase _changeSetting;
  final GetOutgoingCliUseCase _getOutgoingCli;

  ConfirmPresenter(
    CallRepository callRepository,
    SettingRepository settingRepository,
    LoggingRepository loggingRepository,
    AuthRepository authRepository,
  )   : _call = CallUseCase(callRepository),
        _getSettings = GetSettingsUseCase(settingRepository),
        _changeSetting = ChangeSettingUseCase(
          settingRepository,
          loggingRepository,
        ),
        _getOutgoingCli = GetOutgoingCliUseCase(authRepository);

  void call(String destination) => _call(destination: destination).then(
        callOnComplete,
        onError: callOnError,
      );

  void getOutgoingCli() => outgoingCliOnNext(_getOutgoingCli());

  void getSettings() => _getSettings().then(settingsOnNext);

  @override
  void dispose() {}

  // ignore: avoid_positional_boolean_parameters
  void setShowDialogSetting(bool value) {
    _changeSetting(
      setting: ShowDialerConfirmPopupSetting(value),
    );
  }
}

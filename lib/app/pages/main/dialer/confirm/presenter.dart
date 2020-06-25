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

import '../../util/observer.dart';

class ConfirmPresenter extends Presenter {
  Function callOnComplete;
  Function callOnError;

  Function settingsOnNext;

  Function outgoingCliOnNext;

  final CallUseCase _callUseCase;
  final GetSettingsUseCase _getSettingsUseCase;
  final ChangeSettingUseCase _changeSettingUseCase;
  final GetOutgoingCliUseCase _getOutgoingCliUseCase;

  ConfirmPresenter(
    CallRepository callRepository,
    SettingRepository settingRepository,
    LoggingRepository loggingRepository,
    AuthRepository authRepository,
  )   : _callUseCase = CallUseCase(callRepository),
        _getSettingsUseCase = GetSettingsUseCase(settingRepository),
        _changeSettingUseCase = ChangeSettingUseCase(
          settingRepository,
          loggingRepository,
        ),
        _getOutgoingCliUseCase = GetOutgoingCliUseCase(authRepository);

  void call(String destination) {
    _callUseCase.execute(
      Watcher(
        onComplete: callOnComplete,
        onError: callOnError,
      ),
      CallUseCaseParams(destination),
    );
  }

  void getOutgoingCli() => _getOutgoingCliUseCase.execute(
        Watcher(onNext: outgoingCliOnNext),
      );

  void getSettings() => _getSettingsUseCase.execute(
        Watcher(onNext: settingsOnNext),
      );

  @override
  void dispose() {
    _callUseCase.dispose();
  }

  // ignore: avoid_positional_boolean_parameters
  void setShowDialogSetting(bool value) {
    _changeSettingUseCase.execute(
      Watcher(),
      ChangeSettingUseCaseParams(ShowDialerConfirmPopupSetting(value)),
    );
  }
}

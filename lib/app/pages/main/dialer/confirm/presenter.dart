import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../../domain/repositories/call.dart';
import '../../../../../domain/usecases/call.dart';

import '../../../../../domain/entities/setting.dart';
import '../../../../../domain/repositories/setting.dart';
import '../../../../../domain/usecases/get_settings.dart';
import '../../../../../domain/usecases/change_setting.dart';

import '../../../../../domain/repositories/logging.dart';

import '../../util/observer.dart';

class ConfirmPresenter extends Presenter {
  Function callOnComplete;
  Function callOnError;

  Function settingsOnNext;

  final CallUseCase _callUseCase;
  final GetSettingsUseCase _getSettingsUseCase;
  final ChangeSettingUseCase _changeSettingUseCase;

  ConfirmPresenter(
    CallRepository callRepository,
    SettingRepository settingRepository,
    LoggingRepository loggingRepository,
  )   : _callUseCase = CallUseCase(callRepository),
        _getSettingsUseCase = GetSettingsUseCase(settingRepository),
        _changeSettingUseCase = ChangeSettingUseCase(
          settingRepository,
          loggingRepository,
        );

  void call(String destination) {
    _callUseCase.execute(
      Watcher(
        onComplete: callOnComplete,
        onError: callOnError,
      ),
      CallUseCaseParams(destination),
    );
  }

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

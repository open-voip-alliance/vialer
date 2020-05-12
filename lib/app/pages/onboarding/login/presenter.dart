import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../domain/repositories/auth.dart';
import '../../../../domain/repositories/setting.dart';
import '../../../../domain/repositories/logging.dart';

import '../../../../domain/usecases/onboarding/login.dart';
import '../../../../domain/usecases/reset_to_default_settings.dart';

import '../../main/util/observer.dart';

class LoginPresenter extends Presenter {
  Function loginOnNext;
  Function loginOnError;

  Function resetSettingsToDefaultsOnNext;

  final LoginUseCase _loginUseCase;
  final ResetToDefaultSettingsUseCase _resetToDefaultSettingsUseCase;

  LoginPresenter(
    AuthRepository authRepository,
    SettingRepository settingRepository,
    LoggingRepository loggingRepository,
  )   : _loginUseCase = LoginUseCase(authRepository),
        _resetToDefaultSettingsUseCase = ResetToDefaultSettingsUseCase(
          settingRepository,
          loggingRepository,
        );

  void login(String email, String password) {
    _loginUseCase.execute(
      Watcher(
        onError: loginOnError,
        onNext: loginOnNext,
      ),
      LoginUseCaseParams(email, password),
    );
  }

  void resetSettingsToDefaults() {
    _resetToDefaultSettingsUseCase.execute(
      Watcher(
        onNext: (_) => resetSettingsToDefaultsOnNext(),
      ),
    );
  }

  @override
  void dispose() {
    _loginUseCase.dispose();
  }
}

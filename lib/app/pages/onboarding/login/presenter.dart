import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../domain/repositories/auth.dart';
import '../../../../domain/repositories/setting.dart';
import '../../../../domain/repositories/logging.dart';

import '../../../../domain/usecases/onboarding/login.dart';
import '../../../../domain/usecases/reset_settings.dart';

class LoginPresenter extends Presenter {
  Function loginOnNext;
  Function loginOnError;

  Function resetSettingsOnNext;

  final LoginUseCase _login;
  final ResetSettingsUseCase _resetSettings;

  LoginPresenter(
    AuthRepository authRepository,
    SettingRepository settingRepository,
    LoggingRepository loggingRepository,
  )   : _login = LoginUseCase(authRepository),
        _resetSettings = ResetSettingsUseCase(
          settingRepository,
          loggingRepository,
        );

  void login(String email, String password) {
    _login(email: email, password: password).then(
      loginOnNext,
      onError: loginOnError,
    );
  }

  void resetSettingsToDefaults() {
    _resetSettings().then((_) => resetSettingsOnNext());
  }

  @override
  void dispose() {}
}

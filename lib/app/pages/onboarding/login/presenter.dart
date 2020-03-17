import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../domain/repositories/auth.dart';
import '../../../../domain/usecases/onboarding/login.dart';
import '../../../../domain/usecases/reset_to_default_settings.dart';
import '../../../../domain/repositories/setting.dart';

class LoginPresenter extends Presenter {
  Function loginOnNext;
  Function loginOnError;

  Function resetSettingsToDefaultsOnNext;

  final LoginUseCase _loginUseCase;
  final ResetToDefaultSettingsUseCase _resetToDefaultSettingsUseCase;

  LoginPresenter(
    AuthRepository authRepository,
    SettingRepository settingRepository,
  )   : _loginUseCase = LoginUseCase(authRepository),
        _resetToDefaultSettingsUseCase = ResetToDefaultSettingsUseCase(
          settingRepository,
        );

  void login(String email, String password) {
    _loginUseCase.execute(
      _LoginUseCaseObserver(this),
      LoginUseCaseParams(email, password),
    );
  }

  void resetSettingsToDefaults() {
    _resetToDefaultSettingsUseCase.execute(
      _ResetSettingsToDefaultsUseCaseObserver(this),
    );
  }

  @override
  void dispose() {
    _loginUseCase.dispose();
  }
}

class _LoginUseCaseObserver extends Observer<bool> {
  final LoginPresenter presenter;

  _LoginUseCaseObserver(this.presenter);

  @override
  void onComplete() {}

  @override
  void onError(dynamic e) => presenter.loginOnError(e);

  @override
  void onNext(bool success) => presenter.loginOnNext(success);
}

class _ResetSettingsToDefaultsUseCaseObserver extends Observer<bool> {
  final LoginPresenter presenter;

  _ResetSettingsToDefaultsUseCaseObserver(this.presenter);

  @override
  void onComplete() {}

  @override
  void onError(dynamic e) {}

  @override
  void onNext(_) => presenter.resetSettingsToDefaultsOnNext();
}

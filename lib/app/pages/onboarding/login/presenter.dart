import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../domain/repositories/auth.dart';
import '../../../../domain/usecases/onboarding/login.dart';

class LoginPresenter extends Presenter {
  Function loginOnNext;

  final LoginUseCase _loginUseCase;

  LoginPresenter(AuthRepository authRepository)
      : _loginUseCase = LoginUseCase(authRepository);

  void login(String email, String password) {
    _loginUseCase.execute(
      _LoginUseCaseObserver(this),
      LoginUseCaseParams(email, password),
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
  void onError(dynamic e) {}

  @override
  void onNext(bool success) => presenter.loginOnNext(success);
}

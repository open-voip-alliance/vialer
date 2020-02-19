import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:vialer_lite/domain/repositories/auth_repository.dart';
import 'package:vialer_lite/domain/usecases/get_auth_status.dart';

class SplashPresenter extends Presenter {
  Function getAuthStatusOnNext;

  GetAuthStatusUseCase _useCase;

  SplashPresenter(AuthRepository authRepository)
      : _useCase = GetAuthStatusUseCase(authRepository);

  void getAuthStatus() => _useCase.execute(_SplashObserver(this));

  @override
  void dispose() => _useCase.dispose();
}

class _SplashObserver implements Observer<bool> {
  final SplashPresenter _presenter;

  _SplashObserver(this._presenter);

  @override
  void onComplete() {}

  @override
  void onError(e) => onNext(false);

  @override
  void onNext(bool authenticated) =>
      _presenter.getAuthStatusOnNext(authenticated);
}

import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../domain/entities/system_user.dart';
import '../../../../domain/repositories/auth.dart';
import '../../../../domain/usecases/get_current_user.dart';

class WelcomePresenter extends Presenter {
  Function currentUserOnNext;

  final GetCurrentUserUseCase _getCurrentUserUseCase;

  WelcomePresenter(AuthRepository authRepository)
      : _getCurrentUserUseCase = GetCurrentUserUseCase(
          authRepository,
        );

  void getCurrentUser() =>
      _getCurrentUserUseCase.execute(_CurrentUserObserver(this));

  @override
  void dispose() {
    _getCurrentUserUseCase.dispose();
  }
}

class _CurrentUserObserver extends Observer<SystemUser> {
  final WelcomePresenter presenter;

  _CurrentUserObserver(this.presenter);

  @override
  void onComplete() {}

  @override
  void onError(dynamic e) {}

  @override
  void onNext(SystemUser user) => presenter.currentUserOnNext(user);
}

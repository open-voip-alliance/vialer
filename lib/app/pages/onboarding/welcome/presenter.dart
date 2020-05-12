import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../domain/repositories/auth.dart';
import '../../../../domain/usecases/get_current_user.dart';

import '../../main/util/observer.dart';

class WelcomePresenter extends Presenter {
  Function currentUserOnNext;

  final GetCurrentUserUseCase _getCurrentUserUseCase;

  WelcomePresenter(AuthRepository authRepository)
      : _getCurrentUserUseCase = GetCurrentUserUseCase(
          authRepository,
        );

  void getCurrentUser() => _getCurrentUserUseCase.execute(
        Watcher(onNext: currentUserOnNext),
      );

  @override
  void dispose() {
    _getCurrentUserUseCase.dispose();
  }
}

import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../domain/repositories/auth.dart';
import '../../../../domain/usecases/get_current_user.dart';

class WelcomePresenter extends Presenter {
  Function currentUserOnNext;

  final GetCurrentUserUseCase _getCurrentUser;

  WelcomePresenter(AuthRepository authRepository)
      : _getCurrentUser = GetCurrentUserUseCase(
          authRepository,
        );

  void getCurrentUser() => currentUserOnNext(_getCurrentUser());

  @override
  void dispose() {}
}

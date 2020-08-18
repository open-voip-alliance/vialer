import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../domain/usecases/get_current_user.dart';

class WelcomePresenter extends Presenter {
  Function currentUserOnNext;

  final _getCurrentUser = GetCurrentUserUseCase();

  void getCurrentUser() => currentUserOnNext(_getCurrentUser());

  @override
  void dispose() {}
}

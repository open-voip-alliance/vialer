import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_segment/flutter_segment.dart';

import '../../../../domain/usecases/get_current_user.dart';
import '../../../../domain/usecases/onboarding/login.dart';

import '../../../../domain/entities/exceptions/need_to_change_password.dart';

import '../../../util/loggable.dart';
import '../../../util/debug.dart';

import 'state.dart';
export 'state.dart';

class LoginCubit extends Cubit<LoginState> with Loggable {
  final _getStoredUser = GetStoredUserUseCase();
  final _login = LoginUseCase();

  LoginCubit() : super(NotLoggedIn());

  Future<void> login(String username, String password) async {
    logger.info('Logging in');

    emit(LoggingIn());

    var loginSuccessful = false;
    try {
      loginSuccessful = await _login(email: username, password: password);
    } on NeedToChangePasswordException {
      emit(LoggedInAndNeedToChangePassword());
      return;
    }

    if (loginSuccessful) {
      logger.info('Login successful');
      doIfNotDebug(() async {
        await Segment.identify(
          userId: (await _getStoredUser()).uuid,
        );
        await Segment.track(eventName: 'login');
      });

      emit(LoggedIn());
    } else {
      logger.info('Login failed');
      emit(LoginFailed());
    }
  }
}

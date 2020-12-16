import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/entities/exceptions/need_to_change_password.dart';
import '../../../../domain/usecases/metrics/identify_for_tracking.dart';
import '../../../../domain/usecases/metrics/track_login.dart';
import '../../../../domain/usecases/onboarding/login.dart';
import '../../../util/loggable.dart';
import 'state.dart';

export 'state.dart';

class LoginCubit extends Cubit<LoginState> with Loggable {
  final _login = LoginUseCase();
  final _identifyForTracking = IdentifyForTrackingUseCase();
  final _trackLogin = TrackLoginUseCase();

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

      _identifyForTracking();
      _trackLogin();

      emit(LoggedIn());
    } else {
      logger.info('Login failed');
      emit(LoginFailed());
    }
  }
}

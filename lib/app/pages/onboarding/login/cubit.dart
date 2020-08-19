import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_segment/flutter_segment.dart';

import '../../../../domain/usecases/reset_settings.dart';
import '../../../../domain/usecases/get_current_user.dart';
import '../../../../domain/usecases/onboarding/login.dart';

import '../../../../domain/entities/need_to_change_password.dart';

import '../../../util/loggable.dart';
import '../../../util/debug.dart';

import 'state.dart';
export 'state.dart';

class LoginCubit extends Cubit<LoginState> with Loggable {
  final _getCurrentUser = GetCurrentUserUseCase();
  final _login = LoginUseCase();
  final _resetSettings = ResetSettingsUseCase();

  LoginCubit() : super(NotLoggedIn());

  Future<void> login(String username, String password) async {
    logger.info('Logging in');

    emit(LoggingIn());

    var loginSuccesful = false;
    try {
      loginSuccesful = await _login(email: username, password: password);
    } on NeedToChangePassword {
      emit(LoggedInAndNeedToChangePassword());
      return;
    }

    if (loginSuccesful) {
      logger.info('Login successful');
      doIfNotDebug(() async {
        await Segment.identify(
          userId: (await _getCurrentUser()).uuid,
        );
        await Segment.track(eventName: 'login');
      });

      logger.info('Writing default settings');
      _resetSettings();

      emit(LoggedIn());
    } else {
      logger.info('Login failed');
      emit(LoginFailed());
    }
  }
}

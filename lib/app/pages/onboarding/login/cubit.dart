import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/entities/exceptions/need_to_change_password.dart';
import '../../../../domain/entities/onboarding/step.dart';
import '../../../../domain/usecases/get_has_voip.dart';
import '../../../../domain/usecases/get_latest_availability.dart';
import '../../../../domain/usecases/metrics/identify_for_tracking.dart';
import '../../../../domain/usecases/metrics/track_login.dart';
import '../../../../domain/usecases/onboarding/login.dart';
import '../../../util/loggable.dart';
import '../cubit.dart';
import 'state.dart';

export 'state.dart';

class LoginCubit extends Cubit<LoginState> with Loggable {
  final OnboardingCubit _onboarding;

  final _login = LoginUseCase();
  final _identifyForTracking = IdentifyForTrackingUseCase();
  final _trackLogin = TrackLoginUseCase();
  final _getLatestAvailability = GetLatestAvailabilityUseCase();
  final _getHasVoip = GetHasVoipUseCase();

  LoginCubit(this._onboarding) : super(NotLoggedIn());

  Future<void> login(String username, String password) async {
    logger.info('Logging in');

    emit(LoggingIn());

    var loginSuccessful = false;
    try {
      loginSuccessful = await _login(email: username, password: password);
    } on NeedToChangePasswordException {
      _onboarding.addStep(OnboardingStep.password);

      emit(LoggedInAndNeedToChangePassword());

      return;
    }

    if (loginSuccessful) {
      final hasVoip = await _getHasVoip();
      if (hasVoip) {
        _onboarding.addStep(OnboardingStep.microphonePermission);
      }

      emit(LoggedIn());

      logger.info('Login successful');

      await _getLatestAvailability();
      await _identifyForTracking();
      await _trackLogin();

      logger.info('Login successful');
    } else {
      logger.info('Login failed');
      emit(LoginFailed());
    }
  }
}

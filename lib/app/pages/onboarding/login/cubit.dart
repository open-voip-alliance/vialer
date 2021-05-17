import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/entities/exceptions/need_to_change_password.dart';
import '../../../../domain/entities/onboarding/step.dart';
import '../../../../domain/usecases/get_is_voip_allowed.dart';
import '../../../../domain/usecases/get_latest_availability.dart';
import '../../../../domain/usecases/metrics/identify_for_tracking.dart';
import '../../../../domain/usecases/metrics/track_login.dart';
import '../../../../domain/usecases/onboarding/login.dart';
import '../../../util/loggable.dart';
import '../../../util/password.dart' as util;
import '../cubit.dart';
import 'state.dart';

export 'state.dart';

class LoginCubit extends Cubit<LoginState> with Loggable {
  final OnboardingCubit _onboarding;

  final _login = LoginUseCase();
  final _identifyForTracking = IdentifyForTrackingUseCase();
  final _trackLogin = TrackLoginUseCase();
  final _getLatestAvailability = GetLatestAvailabilityUseCase();
  final _getIsVoipAllowed = GetIsVoipAllowed();

  LoginCubit(this._onboarding) : super(NotLoggedIn());

  Future<void> login(String email, String password) async {
    logger.info('Logging in');

    emit(LoggingIn());

    final local = r"[a-z0-9.!#$%&'*+/=?^_`{|}~-]+";
    final domain = '[a-z0-9](?:[a-z0-9-]{0,253}[a-z0-9])?';
    final tld = '(?:\.[a-z0-9](?:[a-z0-9-]{0,253}[a-z0-9])?)+';
    final hasValidEmailFormat = RegExp(
      '^$local@$domain$tld\$',
      caseSensitive: false,
    ).hasMatch(email);
    final hasValidPasswordFormat = util.hasValidPasswordFormat(password);

    if (!hasValidEmailFormat || !hasValidPasswordFormat) {
      emit(
        LoginNotSubmitted(
          hasValidEmailFormat: hasValidEmailFormat,
          hasValidPasswordFormat: hasValidPasswordFormat,
        ),
      );
      return;
    }

    var loginSuccessful = false;
    try {
      loginSuccessful = await _login(email: email, password: password);
    } on NeedToChangePasswordException {
      _onboarding.addStep(OnboardingStep.password);

      emit(LoggedInAndNeedToChangePassword());

      return;
    }

    if (loginSuccessful) {
      final isVoipAllowed = await _getIsVoipAllowed();
      if (isVoipAllowed) {
        _onboarding.addStep(OnboardingStep.microphonePermission);
        _onboarding.addStep(OnboardingStep.mobileNumber);
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

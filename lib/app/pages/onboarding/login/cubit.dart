import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/onboarding/exceptions.dart';
import '../../../../domain/onboarding/login.dart';
import '../../../../domain/onboarding/login_credentials.dart';
import '../../../../domain/onboarding/step.dart';
import '../../../../domain/onboarding/two_factor_authentication_required.dart';
import '../../../../domain/remote_logging/enable_remote_logging_if_needed.dart';
import '../../../../domain/user/get_brand.dart';
import '../../../util/loggable.dart';
import '../../../util/account_validation.dart' as util;

import '../cubit.dart';
import 'state.dart';

export 'state.dart';

class LoginCubit extends Cubit<LoginState> with Loggable {
  LoginCubit(this._onboarding) : super(const NotLoggedIn()) {
    unawaited(_enableRemoteLoggingIfNeeded());
  }

  final OnboardingCubit _onboarding;

  final _enableRemoteLoggingIfNeeded = EnableRemoteLoggingIfNeededUseCase();
  final _login = LoginUseCase();
  final _getBrand = GetBrand();

  Future<void> login(String email, String password) async {
    logger.info('Logging in');

    emit(const LoggingIn());

    final hasValidEmailFormat = util.hasValidEmailFormat(email);
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
      loginSuccessful = await _login(
        credentials: UserProvidedCredentials(
          email: email,
          password: password,
        ),
      );
    } on TwoFactorAuthenticationRequiredException {
      _onboarding.addStep(OnboardingStep.twoFactorAuthentication);

      emit(const LoginRequiresTwoFactorCode());

      return;
    } on NeedToChangePasswordException {
      _onboarding.addStep(OnboardingStep.password);

      emit(const LoggedInAndNeedToChangePassword());

      return;
    }

    if (loginSuccessful) {
      await _onboarding.addStepsBasedOnUserType();

      // We call this again so we're now logging with the user ID, if
      // remote logging was still enabled from a previous session.
      // We await so all future logs are consistently associated with the ID.
      await _enableRemoteLoggingIfNeeded();

      emit(const LoggedIn());

      logger.info('Login successful');
    } else {
      logger.info('Login failed');

      emit(const LoginFailed());
    }
  }

  bool get shouldShowSignUpLink => _getBrand().signUpUrl != null;
}

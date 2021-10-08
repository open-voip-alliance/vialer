import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/entities/exceptions/need_to_change_password.dart';
import '../../../../domain/entities/exceptions/two_factor_authentication_required.dart';
import '../../../../domain/entities/login_credentials.dart';
import '../../../../domain/entities/onboarding/step.dart';
import '../../../../domain/usecases/onboarding/login.dart';
import '../../../util/loggable.dart';
import '../../../util/password.dart' as util;
import '../cubit.dart';
import 'state.dart';

export 'state.dart';

class LoginCubit extends Cubit<LoginState> with Loggable {
  final OnboardingCubit _onboarding;

  final _login = LoginUseCase();

  LoginCubit(this._onboarding) : super(const NotLoggedIn());

  Future<void> login(String email, String password) async {
    logger.info('Logging in');

    emit(const LoggingIn());

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

      emit(const LoggedIn());

      logger.info('Login successful');
    } else {
      logger.info('Login failed');

      emit(const LoginFailed());
    }
  }
}

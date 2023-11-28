import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/authentication/change_password.dart';
import '../../../../domain/onboarding/login.dart';
import '../../../../domain/onboarding/login_credentials.dart';
import '../../../../domain/onboarding/step.dart';
import '../../../../domain/onboarding/two_factor_authentication_required.dart';
import '../../../util/loggable.dart';
import '../../../../domain/authentication/validate_account.dart';
import '../cubit.dart';
import 'state.dart';

export 'state.dart';

class PasswordCubit extends Cubit<PasswordState> with Loggable {
  PasswordCubit(this._onboarding) : super(PasswordNotChanged());
  final OnboardingCubit _onboarding;

  final _changePassword = ChangePasswordUseCase();
  final _login = LoginUseCase();

  Future<void> changePassword(String password) async {
    logger.info('Changing password');

    if (await ValidateAccount.hasValidPasswordFormat(password) == false) {
      emit(PasswordNotAllowed());
      return;
    }

    try {
      final email = _onboarding.state.email!;
      final currentPassword = _onboarding.state.password!;

      await _changePassword(
        email: email,
        currentPassword: currentPassword,
        newPassword: password,
      );

      await _login(
        credentials: UserProvidedCredentials(
          email: email,
          password: password,
        ),
      );

      emit(PasswordChanged());
    } on TwoFactorAuthenticationRequiredException {
      _onboarding.addStep(OnboardingStep.twoFactorAuthentication);

      emit(PasswordChangedButTwoFactorRequired());
    } on Exception {
      // TODO: Other state
      emit(PasswordNotAllowed());
    }
  }
}

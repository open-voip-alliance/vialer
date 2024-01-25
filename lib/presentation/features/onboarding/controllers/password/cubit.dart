import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vialer/dependency_locator.dart';
import 'package:vialer/presentation/util/loggable.dart';

import '../../../../../../data/models/onboarding/login_credentials.dart';
import '../../../../../../data/models/onboarding/step.dart';
import '../../../../../../data/models/onboarding/two_factor_authentication_required.dart';
import '../../../../../../domain/usecases/authentication/change_password.dart';
import '../../../../../../domain/usecases/authentication/validate_password.dart';
import '../../../../../../domain/usecases/onboarding/login.dart';
import '../cubit.dart';
import 'state.dart';

export 'state.dart';

class PasswordCubit extends Cubit<PasswordState> with Loggable {
  PasswordCubit(this._onboarding) : super(PasswordNotChanged());
  final OnboardingCubit _onboarding;

  final _changePassword = ChangePasswordUseCase();
  final _validatePassword = dependencyLocator<ValidatePassword>();
  final _login = LoginUseCase();

  Future<void> changePassword(String password) async {
    logger.info('Changing password');

    if (await _validatePassword(password) == false) {
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

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/exceptions/two_factor_authentication_required.dart';
import '../../../../domain/entities/onboarding/step.dart';

import '../../../../domain/usecases/change_password.dart';
import '../../../../domain/usecases/onboarding/login.dart';
import '../../../util/loggable.dart';
import '../../../util/password.dart';
import '../cubit.dart';
import 'state.dart';

export 'state.dart';

class PasswordCubit extends Cubit<PasswordState> with Loggable {
  final OnboardingCubit _onboarding;

  final _changePassword = ChangePasswordUseCase();
  final _login = LoginUseCase();

  PasswordCubit(this._onboarding) : super(PasswordNotChanged());

  Future<void> changePassword(String password) async {
    logger.info('Changing password');

    if (!hasValidPasswordFormat(password)) {
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
        email: email,
        password: password,
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

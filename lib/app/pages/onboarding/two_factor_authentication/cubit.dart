import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/onboarding/login.dart';
import '../../../../domain/onboarding/login_credentials.dart';
import '../../../../domain/onboarding/need_to_change_password.dart';
import '../../../../domain/onboarding/step.dart';
import '../../../util/loggable.dart';
import '../cubit.dart';
import 'state.dart';

export 'state.dart';

class TwoFactorAuthenticationCubit extends Cubit<TwoFactorState> with Loggable {
  final OnboardingCubit _onboarding;

  final _login = LoginUseCase();

  TwoFactorAuthenticationCubit(this._onboarding)
      : super(const CodeNotSubmitted());

  Future<void> attemptLoginWithTwoFactorCode(String code) async {
    emit(const AwaitingServerResponse());

    logger.info('Attempting to login using two-factor code');

    try {
      await _handleLoginResult(
        await _login(
          credentials: UserProvidedCredentials(
            email: _onboarding.state.email!,
            password: _onboarding.state.password!,
            twoFactorCode: code,
          ),
        ),
      );
    } on NeedToChangePasswordException {
      logger.info('User must change their password');

      _onboarding.addStep(OnboardingStep.password);

      emit(const PasswordChangeRequired());

      return;
    } on Exception {
      logger.severe('Received exception while attempting to log user in.');

      emit(const CodeRejected());

      rethrow;
    }
  }

  Future<void> _handleLoginResult(bool result) async {
    if (!result) {
      logger.info('Two-factor code was rejected.');

      emit(const CodeRejected());

      return;
    }

    logger.info('Two-factor code accepted, logging user in.');

    await _onboarding.addStepsBasedOnUserType();

    emit(const CodeAccepted());
  }
}

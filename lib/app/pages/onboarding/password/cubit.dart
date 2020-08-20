import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/usecases/get_current_user.dart';
import '../../../../domain/usecases/onboarding/login.dart';
import '../../../../domain/usecases/change_password.dart';

import '../cubit.dart';

import '../../../util/loggable.dart';

import 'state.dart';
export 'state.dart';

class PasswordCubit extends Cubit<PasswordState> with Loggable {
  final OnboardingCubit _onboarding;

  final _changePassword = ChangePasswordUseCase();
  final _login = LoginUseCase();
  final _getCurrentUser = GetCurrentUserUseCase();

  PasswordCubit(this._onboarding) : super(PasswordNotChanged());

  Future<void> changePassword(String password) async {
    logger.info('Changing password');

    if (password.length < 6 || !RegExp(r'[^A-z]').hasMatch(password)) {
      emit(PasswordNotAllowed());
      return;
    }

    try {
      await _changePassword(
        currentPassword: _onboarding.state.password,
        newPassword: password,
      );
      await _login(
        email: _getCurrentUser().email,
        password: password,
      );

      emit(PasswordChanged());
    } on Exception {
      // TODO: Other state
      emit(PasswordNotAllowed());
    }
  }
}

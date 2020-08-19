import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/usecases/change_password.dart';

import '../../../util/loggable.dart';

import 'state.dart';
export 'state.dart';

class PasswordCubit extends Cubit<PasswordState> with Loggable {
  final _changePassword = ChangePasswordUseCase();

  PasswordCubit() : super(PasswordNotChanged());

  Future<void> changePassword(String password) async {
    logger.info('Changing password');

    if (password.length < 6 || !RegExp(r'[^A-z]').hasMatch(password)) {
      emit(PasswordNotAllowed());
      return;
    }

    try {
      await _changePassword(newPassword: password);
    } on Exception {
      // TODO: Other state
      emit(PasswordNotAllowed());
    }
  }
}

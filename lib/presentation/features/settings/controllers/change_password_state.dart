import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vialer/dependency_locator.dart';
import 'package:vialer/domain/usecases/authentication/change_password.dart';
import 'package:vialer/domain/usecases/authentication/logout.dart';
import 'package:vialer/domain/usecases/authentication/validate_password.dart';
import 'package:vialer/presentation/resources/localizations.dart';
import 'package:vialer/presentation/resources/messages.i18n.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'change_password_state.freezed.dart';

@freezed
class ChangePasswordState with _$ChangePasswordState {
  const factory ChangePasswordState({
    required String errorOldPassword,
    required String errorNewPassword,
  }) = _ChangePasswordState;
}

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  ChangePasswordCubit()
      : super(
          ChangePasswordState(
            errorOldPassword: '',
            errorNewPassword: '',
          ),
        );

  late final _validatePassword = dependencyLocator<ValidatePassword>();
  late final _changePassword = ChangePasswordUseCase();
  late final _logout = Logout();

  void setNewError(String message) =>
      emit(state.copyWith(errorNewPassword: message));
  void setOldError(String message) =>
      emit(state.copyWith(errorOldPassword: message));
  void clearNewError() => setNewError('');
  void clearOldError() => setOldError('');

  bool get hasErrors {
    return state.errorOldPassword != '' || state.errorNewPassword != '';
  }

  Future<bool> savePasswordHandler({
    required BuildContext context,
    required String newPassword,
    required String oldPassword,
  }) async {
    clearOldError();
    clearNewError();

    if (oldPassword.isEmpty) {
      setOldError(context.strings.errors.oldPasswordEmpty);
    }

    if (newPassword.isEmpty) {
      setNewError(context.strings.errors.newPasswordEmpty);
    } else if (!await _validatePassword(newPassword)) {
      setNewError(context.strings.errors.invalidRequirements);
    } else if (oldPassword == newPassword) {
      // Note that the API also checks for using the same password.
      setNewError(context.strings.errors.usingSameAsCurrent);
    }

    if (hasErrors) {
      return false;
    }

    if (await _changePassword(
      currentPassword: oldPassword,
      newPassword: newPassword,
    )) {
      // Password succesfully changed!
      return true;
    } else {
      // Error changing password.
      // Since we already checked requirements, the only practical reason
      // this happens is because the old password is invalid.
      setOldError(context.strings.errors.currentInvalid);
      return false;
    }
  }

  Future<void> logout() async => _logout();
}

extension on BuildContext {
  ChangePasswordSettingsMainMessages get strings =>
      msg.main.settings.changePassword;
}

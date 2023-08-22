import 'package:freezed_annotation/freezed_annotation.dart';

part 'state.freezed.dart';

@freezed
sealed class PasswordState with _$PasswordState {
  const factory PasswordState.notChanged() = PasswordNotChanged;
  const factory PasswordState.notAllowed() = PasswordNotAllowed;
  const factory PasswordState.changed() = PasswordChanged;
  const factory PasswordState.changedButTwoFactorRequired() =
      PasswordChangedButTwoFactorRequired;
}

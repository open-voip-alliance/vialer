import 'package:freezed_annotation/freezed_annotation.dart';

part 'state.freezed.dart';

@freezed
sealed class PasswordForgottenState with _$PasswordForgottenState {
  const factory PasswordForgottenState.initial() = Initial;
  const factory PasswordForgottenState.loading() = Loading;
  const factory PasswordForgottenState.success() = Success;
  const factory PasswordForgottenState.failure() = Failure;
  const factory PasswordForgottenState.notSubmitted({
    required bool hasValidEmailFormat,
  }) = NotSubmitted;
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'state.freezed.dart';

@freezed
sealed class TwoFactorState with _$TwoFactorState {
  const factory TwoFactorState.codeNotSubmitted() = CodeNotSubmitted;
  const factory TwoFactorState.awaitingServerResponse() =
      AwaitingServerResponse;
  const factory TwoFactorState.codeAccepted() = CodeAccepted;
  const factory TwoFactorState.passwordChangeRequired() =
      PasswordChangeRequired;
  const factory TwoFactorState.codeRejected() = CodeRejected;
}

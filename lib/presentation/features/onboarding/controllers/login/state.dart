import 'package:freezed_annotation/freezed_annotation.dart';

part 'state.freezed.dart';

@freezed
sealed class LoginState with _$LoginState {
  const factory LoginState.notLoggedIn() = NotLoggedIn;
  const factory LoginState.loggingIn() = LoggingIn;
  const factory LoginState.loginFailed() = LoginFailed;
  const factory LoginState.loginRequiresTwoFactorCode() =
      LoginRequiresTwoFactorCode;
  const factory LoginState.loggedIn() = LoggedIn;
  const factory LoginState.loggedInAndNeedToChangePassword() =
      LoggedInAndNeedToChangePassword;
  const factory LoginState.loginNotSubmitted({
    required bool hasValidEmailFormat,
    required bool hasValidPasswordFormat,
  }) = LoginNotSubmitted;
}

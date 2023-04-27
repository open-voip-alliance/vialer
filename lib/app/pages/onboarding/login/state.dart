import 'package:equatable/equatable.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

class NotLoggedIn extends LoginState {
  const NotLoggedIn();
}

class LoggingIn extends LoginState {
  const LoggingIn();
}

class LoginFailed extends LoginState {
  const LoginFailed();
}

class LoginRequiresTwoFactorCode extends LoginState {
  const LoginRequiresTwoFactorCode();
}

class LoginNotSubmitted extends LoginState {
  const LoginNotSubmitted({
    required this.hasValidEmailFormat,
    required this.hasValidPasswordFormat,
  });

  final bool hasValidEmailFormat;
  final bool hasValidPasswordFormat;

  @override
  List<Object?> get props => [hasValidEmailFormat, hasValidPasswordFormat];
}

class LoggedIn extends LoginState {
  const LoggedIn();
}

class LoggedInAndNeedToChangePassword extends LoggedIn {
  const LoggedInAndNeedToChangePassword();
}

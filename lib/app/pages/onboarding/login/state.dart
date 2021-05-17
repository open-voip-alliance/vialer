import 'package:equatable/equatable.dart';

abstract class LoginState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NotLoggedIn extends LoginState {}

class LoggingIn extends LoginState {}

class LoginFailed extends LoginState {}

class LoginNotSubmitted extends LoginState {
  final bool hasValidEmailFormat;
  final bool hasValidPasswordFormat;

  LoginNotSubmitted({
    required this.hasValidEmailFormat,
    required this.hasValidPasswordFormat,
  });

  @override
  List<Object?> get props => [hasValidEmailFormat, hasValidPasswordFormat];
}

class LoggedIn extends LoginState {}

class LoggedInAndNeedToChangePassword extends LoggedIn {}

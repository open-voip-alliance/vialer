import 'package:equatable/equatable.dart';

abstract class LoginState extends Equatable {
  @override
  List<Object> get props => [];
}

class NotLoggedIn extends LoginState {}

class LoggingIn extends LoginState {}

class LoginFailed extends LoginState {}

class LoggedIn extends LoginState {}

class LoggedInAndNeedToChangePassword extends LoggedIn {}

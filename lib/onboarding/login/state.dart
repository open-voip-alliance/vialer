import 'package:equatable/equatable.dart';

abstract class LoginState extends Equatable {
  @override
  List<Object> get props => [];
}

class NotLoggedIn extends LoginState {}

class LoginSuccessful extends LoginState {}

class LoginFailed extends LoginState {}

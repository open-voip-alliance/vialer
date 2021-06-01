import 'package:equatable/equatable.dart';

abstract class PasswordState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PasswordNotChanged extends PasswordState {}

class PasswordNotAllowed extends PasswordState {}

class PasswordChanged extends PasswordState {}

class PasswordChangedButTwoFactorRequired extends PasswordChanged {}

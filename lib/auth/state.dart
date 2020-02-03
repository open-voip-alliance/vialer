import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object> get props => [];
}

class Uninitialized extends AuthState {}

class NotAuthenticated extends AuthState {}

class Authenticated extends AuthState {}

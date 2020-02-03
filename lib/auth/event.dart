import 'package:equatable/equatable.dart';

import 'package:meta/meta.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class Check extends AuthEvent {}

class LoggedIn extends AuthEvent {
  final String email;
  final String token;

  LoggedIn({@required this.email, @required this.token});

  List<Object> get props => [token];
}

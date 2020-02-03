import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {}

class Login extends LoginEvent {
  final String username;
  final String password;

  Login({@required this.username, @required this.password});

  @override
  List<Object> get props => [username, password];
}

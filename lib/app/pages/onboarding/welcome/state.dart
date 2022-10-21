import 'package:equatable/equatable.dart';

import '../../../../domain/user/user.dart';

class WelcomeState extends Equatable {
  final User? user;

  WelcomeState({this.user});

  @override
  List<Object?> get props => [user];
}

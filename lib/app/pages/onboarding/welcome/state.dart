import 'package:equatable/equatable.dart';

import '../../../../domain/user/user.dart';

class WelcomeState extends Equatable {
  const WelcomeState({this.user});

  final User? user;

  @override
  List<Object?> get props => [user];
}

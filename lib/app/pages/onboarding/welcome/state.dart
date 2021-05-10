import 'package:equatable/equatable.dart';

import '../../../../domain/entities/system_user.dart';

class WelcomeState extends Equatable {
  final SystemUser? user;

  WelcomeState({this.user});

  @override
  List<Object?> get props => [user];
}

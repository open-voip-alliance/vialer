import 'package:equatable/equatable.dart';

abstract class UserDataRefresherState extends Equatable {
  const UserDataRefresherState();

  @override
  List<Object> get props => [];
}

class NotRefreshing extends UserDataRefresherState {
  const NotRefreshing();
}

class Refreshing extends UserDataRefresherState {
  const Refreshing();
}

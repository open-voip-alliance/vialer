import 'package:equatable/equatable.dart';

abstract class UserRefresherState extends Equatable {
  const UserRefresherState();

  @override
  List<Object> get props => [];
}

class NotRefreshing extends UserRefresherState {
  const NotRefreshing();
}

class Refreshing extends UserRefresherState {
  const Refreshing();
}

class Refreshed extends UserRefresherState {
  const Refreshed();
}

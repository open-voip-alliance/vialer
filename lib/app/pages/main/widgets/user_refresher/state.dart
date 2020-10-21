import 'package:equatable/equatable.dart';

abstract class UserRefresherState extends Equatable {
  @override
  List<Object> get props => [];
}

class NotRefreshing extends UserRefresherState {}

class Refreshing extends UserRefresherState {}

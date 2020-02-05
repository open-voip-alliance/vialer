import 'package:equatable/equatable.dart';

abstract class RecentEvent extends Equatable {
  const RecentEvent();

  @override
  List<Object> get props => [];
}

class LoadRecents extends RecentEvent {}

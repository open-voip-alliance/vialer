import 'package:equatable/equatable.dart';
import 'package:vialer_lite/main/recent/item.dart';

abstract class RecentState extends Equatable {
  const RecentState();

  @override
  List<Object> get props => [];
}

class RecentsLoaded extends RecentState {
  final List<RecentCall> items;

  RecentsLoaded(this.items);

  @override
  List<Object> get props => [items];
}

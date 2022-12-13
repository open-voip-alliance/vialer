import 'package:equatable/equatable.dart';

abstract class T9ColltactsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadColltacts extends T9ColltactsEvent {}

class FilterT9Colltacts extends T9ColltactsEvent {
  final String input;

  FilterT9Colltacts(this.input);

  @override
  List<Object?> get props => [input];
}

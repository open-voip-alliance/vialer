import 'package:equatable/equatable.dart';

abstract class Destination extends Equatable {
  int get id;

  const Destination();

  @override
  List<Object> get props => [id];
}

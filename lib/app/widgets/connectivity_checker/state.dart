import 'package:equatable/equatable.dart';

abstract class ConnectivityState extends Equatable {
  @override
  List<Object?> get props => [];
}

class Connected extends ConnectivityState {}

class Disconnected extends ConnectivityState {}

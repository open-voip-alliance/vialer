import 'package:equatable/equatable.dart';

abstract class DialerState extends Equatable {
  const DialerState();
}

class Dialing extends DialerState {
  @override
  List<Object> get props => [];
}

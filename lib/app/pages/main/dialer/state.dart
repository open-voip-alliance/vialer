import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class DialerState extends Equatable {
  @override
  List<Object> get props => [];
}

class NoPermission extends DialerState {
  final bool dontAskAgain;

  NoPermission({@required this.dontAskAgain});

  @override
  List<Object> get props => [dontAskAgain];
}

class CanCall extends DialerState {
  final String lastCalledDestination;

  CanCall({this.lastCalledDestination});

  @override
  List<Object> get props => [lastCalledDestination];
}

class CallInitiated extends DialerState {}

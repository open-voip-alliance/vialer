import 'package:equatable/equatable.dart';

class DialerState extends Equatable {
  final String? lastCalledDestination;

  DialerState({this.lastCalledDestination});

  @override
  List<Object?> get props => [lastCalledDestination];
}

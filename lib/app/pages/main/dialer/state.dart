import 'package:equatable/equatable.dart';

class DialerState extends Equatable {
  const DialerState({this.lastCalledDestination});

  final String? lastCalledDestination;

  @override
  List<Object?> get props => [lastCalledDestination];
}

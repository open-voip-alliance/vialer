import 'package:equatable/equatable.dart';

abstract class DialerEvent extends Equatable {
  const DialerEvent();
}

class Call extends DialerEvent {
  final String phoneNumber;

  const Call(this.phoneNumber);

  @override
  List<Object> get props => [phoneNumber];
}

import 'package:equatable/equatable.dart';

abstract class DialerEvent extends Equatable {
  const DialerEvent();
}

class Call extends DialerEvent {
  final String phoneNumber;
  final bool showedConfirmation;

  const Call(this.phoneNumber, {this.showedConfirmation = false});

  @override
  List<Object> get props => [phoneNumber, showedConfirmation];
}

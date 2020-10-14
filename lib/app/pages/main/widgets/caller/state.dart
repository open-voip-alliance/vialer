import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../../../domain/entities/call_through_exception.dart';

abstract class CallerState extends Equatable {
  @override
  List<Object> get props => [];
}

class CanCall extends CallerState {}

class ShowConfirmPage extends CallerState {
  final String destination;

  ShowConfirmPage({@required this.destination});

  @override
  List<Object> get props => [destination];
}

class InitiatingCall extends CallerState {}

class InitiatingCallFailed extends CallerState {
  final CallThroughException exception;

  InitiatingCallFailed(this.exception);

  @override
  List<Object> get props => [exception];
}

class Calling extends CallerState {}

class ShowCallThroughSurvey extends CallerState {}

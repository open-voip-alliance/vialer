import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../../../domain/entities/exceptions/call_through.dart';

abstract class CallerState extends Equatable {
  @override
  List<Object> get props => [];
}

class NoPermission extends CallerState {
  final bool dontAskAgain;

  NoPermission({@required this.dontAskAgain});

  @override
  List<Object> get props => [dontAskAgain];
}

class CanCall extends CallerState {}

class ShowConfirmPage extends CallerState with CallProcessState {
  final String destination;

  @override
  final CallOrigin origin;

  ShowConfirmPage({@required this.destination, @required this.origin});

  @override
  List<Object> get props => [...super.props, destination];
}

class InitiatingCall extends CallerState with CallProcessState {
  @override
  final CallOrigin origin;

  InitiatingCall({@required this.origin});

  InitiatingCallFailed failed(CallThroughException exception) =>
      InitiatingCallFailed(exception, origin: origin);

  Calling calling() => Calling(origin: origin);
}

class InitiatingCallFailed extends CallerState with CallProcessState {
  @override
  final CallOrigin origin;

  final CallThroughException exception;

  InitiatingCallFailed(
    this.exception, {
    @required this.origin,
  });

  @override
  List<Object> get props => [...super.props, exception];
}

class Calling extends CallerState with CallProcessState {
  @override
  final CallOrigin origin;

  Calling({@required this.origin});

  FinishedCalling finished() => FinishedCalling(origin: origin);

  ShowCallThroughSurvey showCallThroughSurvey() =>
      ShowCallThroughSurvey(origin: origin);
}

class FinishedCalling extends CanCall with CallProcessState {
  @override
  final CallOrigin origin;

  FinishedCalling({@required this.origin});
}

class ShowCallThroughSurvey extends FinishedCalling {
  ShowCallThroughSurvey({@required CallOrigin origin}) : super(origin: origin);

  ShowedCallThroughSurvey showed() => ShowedCallThroughSurvey(origin: origin);
}

class ShowedCallThroughSurvey extends FinishedCalling {
  ShowedCallThroughSurvey({
    @required CallOrigin origin,
  }) : super(origin: origin);
}

/// Any state that is part of the actual call process:
/// start, during, end, etc.
mixin CallProcessState on CallerState {
  CallOrigin get origin;

  @override
  List<Object> get props => [...super.props, origin];
}

/// Where the call started in the UI: dialer, recents, contacts, etc.
enum CallOrigin {
  dialer,
  recents,
  contacts,
}

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

  @override
  final bool useVoip;

  ShowConfirmPage({
    @required this.destination,
    @required this.origin,
    this.useVoip,
  });

  @override
  List<Object> get props => [...super.props, destination];
}

class InitiatingCall extends CallerState with CallProcessState {
  @override
  final CallOrigin origin;

  @override
  final bool useVoip;

  InitiatingCall({@required this.origin, @required this.useVoip});

  InitiatingCallFailed failed(CallThroughException exception) =>
      InitiatingCallFailed(exception, origin: origin, useVoip: useVoip);

  Calling calling() => Calling(origin: origin, useVoip: useVoip);
}

class InitiatingCallFailed extends CallerState with CallProcessState {
  @override
  final CallOrigin origin;

  @override
  final bool useVoip;

  final CallThroughException exception;

  InitiatingCallFailed(
    this.exception, {
    @required this.origin,
    @required this.useVoip,
  });

  @override
  List<Object> get props => [...super.props, exception];
}

class Calling extends CallerState with CallProcessState {
  @override
  final CallOrigin origin;

  @override
  final bool useVoip;

  Calling({
    @required this.origin,
    @required this.useVoip,
  });

  FinishedCalling finished() => FinishedCalling(
        origin: origin,
        useVoip: useVoip,
      );

  ShowCallThroughSurvey showCallThroughSurvey() =>
      ShowCallThroughSurvey(origin: origin, useVoip: useVoip);
}

class FinishedCalling extends CanCall with CallProcessState {
  @override
  final CallOrigin origin;

  @override
  final bool useVoip;

  FinishedCalling({
    @required this.origin,
    @required this.useVoip,
  });
}

class ShowCallThroughSurvey extends FinishedCalling {
  ShowCallThroughSurvey({
    @required CallOrigin origin,
    @required bool useVoip,
  }) : super(origin: origin, useVoip: useVoip);

  ShowedCallThroughSurvey showed() => ShowedCallThroughSurvey(
        origin: origin,
        useVoip: useVoip,
      );
}

class ShowedCallThroughSurvey extends FinishedCalling {
  ShowedCallThroughSurvey({
    @required CallOrigin origin,
    @required bool useVoip,
  }) : super(origin: origin, useVoip: useVoip);
}

/// Any state that is part of the actual call process:
/// start, during, end, etc.
mixin CallProcessState on CallerState {
  CallOrigin get origin;

  bool get useVoip;

  @override
  List<Object> get props => [...super.props, origin, useVoip];
}

/// Where the call started in the UI: dialer, recents, contacts, etc.
enum CallOrigin {
  dialer,
  recents,
  contacts,
}

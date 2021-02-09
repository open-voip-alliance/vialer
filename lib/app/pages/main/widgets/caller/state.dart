import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:voip_flutter_integration/voip_flutter_integration.dart';

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
  final FilCall call;

  ShowConfirmPage({
    @required this.destination,
    @required this.origin,
    this.call,
  });

  @override
  List<Object> get props => [...super.props, destination];
}

class InitiatingCall extends CallerState with CallProcessState {
  @override
  final CallOrigin origin;

  @override
  final FilCall call;

  InitiatingCall({@required this.origin, this.call});
}

class InitiatingCallFailed extends CallerState with CallProcessState {
  @override
  final CallOrigin origin;

  @override
  final FilCall call;

  final CallThroughException exception;

  InitiatingCallFailed(
    this.exception, {
    @required this.origin,
    @required this.call,
  });

  @override
  List<Object> get props => [...super.props, exception];
}

class Calling extends CallerState with CallProcessState {
  @override
  final CallOrigin origin;

  @override
  final FilCall call;

  Calling({
    @required this.origin,
    @required this.call,
  });
}

class FinishedCalling extends CanCall with CallProcessState {
  @override
  final CallOrigin origin;

  @override
  final FilCall call;

  FinishedCalling({
    @required this.origin,
    @required this.call,
  });
}

class ShowCallThroughSurvey extends FinishedCalling {
  ShowCallThroughSurvey({@required CallOrigin origin})
      // Call does not need to be passed here since it's for call-through.
      : super(origin: origin, call: null);

  ShowedCallThroughSurvey showed() => ShowedCallThroughSurvey(
        origin: origin,
      );
}

class ShowedCallThroughSurvey extends FinishedCalling {
  ShowedCallThroughSurvey({
    @required CallOrigin origin,
  }) // Call does not need to be passed here since it's for call-through.
  : super(origin: origin, call: null);
}

/// Any state that is part of the actual call process:
/// start, during, end, etc.
mixin CallProcessState on CallerState {
  CallOrigin get origin;

  FilCall get call;

  // `call` is only available when it's a VoIP call.
  bool get isVoip => call != null;

  @override
  List<Object> get props => [...super.props, origin, call, isVoip];

  InitiatingCallFailed failed(CallThroughException exception) {
    assert(this is InitiatingCall);

    return InitiatingCallFailed(exception, origin: origin, call: call);
  }

  Calling calling({FilCall call}) {
    return Calling(origin: origin, call: call ?? this.call);
  }

  ShowCallThroughSurvey showCallThroughSurvey() {
    assert(this is Calling);

    return ShowCallThroughSurvey(origin: origin);
  }

  FinishedCalling finished() {
    return FinishedCalling(
      origin: origin,
      call: call,
    );
  }
}

/// Where the call started in the UI: dialer, recents, contacts, etc.
enum CallOrigin {
  dialer,
  recents,
  contacts,
}

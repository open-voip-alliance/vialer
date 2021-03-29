import 'package:equatable/equatable.dart';
import 'package:flutter_phone_lib/call/call.dart';
import 'package:meta/meta.dart';

import '../../../../../domain/entities/exceptions/call_through.dart';

abstract class CallerState extends Equatable {
  const CallerState();

  @override
  List<Object> get props => [];
}

class NoPermission extends CallerState {
  final bool dontAskAgain;

  const NoPermission({@required this.dontAskAgain});

  @override
  List<Object> get props => [dontAskAgain];
}

class CanCall extends CallerState {
  const CanCall();
}

/// Used only to pass the [origin] to future states.
class CallOriginDetermined extends CallerState {
  /// Where the call started in the UI: dialer, recents, contacts, etc.
  /// Can be null if it's an incoming call.
  final CallOrigin origin;

  const CallOriginDetermined(this.origin);

  @override
  List<Object> get props => [...super.props, origin];
}

class ShowCallThroughConfirmPage extends CallOriginDetermined {
  final String destination;

  const ShowCallThroughConfirmPage({
    @required this.destination,
    CallOrigin origin,
  }) : super(origin);

  @override
  List<Object> get props => [...super.props, destination];
}

/// Not to be confused with SIP's Ringing method. Because of the layers of
/// abstraction, we only use [Ringing] to indicate that our app is ringing
/// because of an incoming call.
///
/// See [InitiatingCall] for the outgoing equivalent.
class Ringing extends CallerState with CallProcessState {
  @override
  final origin = CallOrigin.incoming;

  @override
  final Call call;

  const Ringing({@required this.call});
}

class InitiatingCall extends CallerState with CallProcessState {
  @override
  final CallOrigin origin;

  @override
  final Call call;

  const InitiatingCall({@required this.origin, this.call});

  InitiatingCall copyWith({CallOrigin origin, Call call}) {
    return InitiatingCall(
      origin: origin ?? this.origin,
      call: call ?? this.call,
    );
  }
}

class InitiatingCallFailed extends CallerState with CallProcessState {
  @override
  final CallOrigin origin;

  @override
  final Call call;

  final CallThroughException exception;

  const InitiatingCallFailed(
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
  final Call call;

  const Calling({
    @required this.origin,
    @required this.call,
  });

  Calling copyWith({CallOrigin origin, Call call}) {
    return Calling(
      origin: origin ?? this.origin,
      call: call ?? this.call,
    );
  }
}

class FinishedCalling extends CanCall with CallProcessState {
  @override
  final CallOrigin origin;

  @override
  final Call call;

  const FinishedCalling({
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
  const ShowedCallThroughSurvey({
    @required CallOrigin origin,
  }) // Call does not need to be passed here since it's for call-through.
  : super(origin: origin, call: null);
}

/// Any state that is part of the actual call process:
/// start, during, end, etc.
mixin CallProcessState on CallerState implements CallOriginDetermined {
  @override
  CallOrigin get origin;

  Call get call;

  // `call` is only available when it's a VoIP call.
  bool get isVoip => call != null;

  @override
  List<Object> get props => [...super.props, origin, call, isVoip];

  InitiatingCallFailed failed(CallThroughException exception) {
    assert(this is InitiatingCall);

    return InitiatingCallFailed(exception, origin: origin, call: call);
  }

  Calling calling({Call call}) {
    return Calling(origin: origin, call: call ?? this.call);
  }

  ShowCallThroughSurvey showCallThroughSurvey() {
    assert(this is Calling);

    return ShowCallThroughSurvey(origin: origin);
  }

  FinishedCalling finished({Call call}) {
    return FinishedCalling(
      origin: origin,
      call: call ?? this.call,
    );
  }
}

enum CallOrigin {
  incoming,
  dialer,
  recents,
  contacts,
}

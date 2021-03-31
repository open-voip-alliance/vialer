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

/// Any state that is part of the actual call process:
/// start, during, end, etc.
abstract class CallProcessState extends CallOriginDetermined {
  final Call voipCall;

  // `voipCall` is only available when it's a VoIP call.
  bool get isVoip => voipCall != null;

  /// Irrelevant (and always false) if [isVoip] is false.
  final bool isVoipCallMuted;

  const CallProcessState({
    @required CallOrigin origin,
    @required this.voipCall,
    bool isVoipCallMuted,
  })  : isVoipCallMuted = isVoipCallMuted ?? false,
        super(origin);

  @override
  List<Object> get props => [
        ...super.props,
        origin,
        voipCall,
        isVoip,
        isVoipCallMuted,
      ];

  CallProcessState copyWith({
    CallOrigin origin,
    Call voipCall,
    bool isVoipCallMuted,
  });

  InitiatingCallFailed failed(CallThroughException exception) {
    assert(this is InitiatingCall);

    return InitiatingCallFailed(exception, origin: origin, voipCall: voipCall);
  }

  Calling calling({Call voipCall}) {
    return Calling(origin: origin, voipCall: voipCall ?? this.voipCall);
  }

  ShowCallThroughSurvey showCallThroughSurvey() {
    assert(this is Calling);

    return ShowCallThroughSurvey(origin: origin);
  }

  FinishedCalling finished({Call voipCall}) {
    return FinishedCalling(
      origin: origin,
      voipCall: voipCall ?? this.voipCall,
    );
  }
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
class Ringing extends CallProcessState {
  const Ringing({
    @required Call voipCall,
    bool isVoipCallMuted,
  }) : super(
          origin: CallOrigin.incoming,
          voipCall: voipCall,
          isVoipCallMuted: isVoipCallMuted,
        );

  /// [origin] never gets copied (is always [CallOrigin.incoming]).
  @override
  Ringing copyWith({
    CallOrigin origin,
    Call voipCall,
    bool isVoipCallMuted,
  }) {
    return Ringing(
      voipCall: voipCall ?? this.voipCall,
      isVoipCallMuted: isVoipCallMuted ?? this.isVoipCallMuted,
    );
  }
}

class InitiatingCall extends CallProcessState {
  const InitiatingCall({
    @required CallOrigin origin,
    Call voipCall,
    bool isVoipCallMuted = false,
  }) : super(
          origin: origin,
          voipCall: voipCall,
          isVoipCallMuted: isVoipCallMuted,
        );

  @override
  InitiatingCall copyWith({
    CallOrigin origin,
    Call voipCall,
    bool isVoipCallMuted,
  }) {
    return InitiatingCall(
      origin: origin ?? this.origin,
      voipCall: voipCall ?? this.voipCall,
      isVoipCallMuted: isVoipCallMuted ?? this.isVoipCallMuted,
    );
  }
}

class InitiatingCallFailed extends CallProcessState {
  final Exception exception;

  const InitiatingCallFailed(
    this.exception, {
    @required CallOrigin origin,
    @required Call voipCall,
    bool isVoipCallMuted,
  }) : super(
          origin: origin,
          voipCall: voipCall,
          isVoipCallMuted: isVoipCallMuted,
        );

  @override
  List<Object> get props => [...super.props, exception];

  @override
  InitiatingCallFailed copyWith({
    Exception exception,
    CallOrigin origin,
    Call voipCall,
    bool isVoipCallMuted,
  }) {
    return InitiatingCallFailed(
      exception ?? this.exception,
      origin: origin ?? this.origin,
      voipCall: voipCall ?? this.voipCall,
      isVoipCallMuted: isVoipCallMuted ?? this.isVoipCallMuted,
    );
  }
}

class Calling extends CallProcessState {
  const Calling({
    @required CallOrigin origin,
    @required Call voipCall,
    bool isVoipCallMuted,
  }) : super(
          origin: origin,
          voipCall: voipCall,
          isVoipCallMuted: isVoipCallMuted,
        );
  
  @override
  Calling copyWith({
    CallOrigin origin,
    Call voipCall,
    bool isVoipCallMuted,
  }) {
    return Calling(
      origin: origin ?? this.origin,
      voipCall: voipCall ?? this.voipCall,
      isVoipCallMuted: isVoipCallMuted ?? this.isVoipCallMuted,
    );
  }
}

class FinishedCalling extends CallProcessState implements CanCall {
  const FinishedCalling({
    @required CallOrigin origin,
    @required Call voipCall,
    bool isVoipCallMuted,
  }) : super(
          origin: origin,
          voipCall: voipCall,
          isVoipCallMuted: isVoipCallMuted,
        );
  
  @override
  FinishedCalling copyWith({
    CallOrigin origin,
    Call voipCall,
    bool isVoipCallMuted,
  }) {
    return FinishedCalling(
      origin: origin ?? this.origin,
      voipCall: voipCall ?? this.voipCall,
      isVoipCallMuted: isVoipCallMuted ?? this.isVoipCallMuted,
    );
  }
}

class ShowCallThroughSurvey extends FinishedCalling {
  ShowCallThroughSurvey({@required CallOrigin origin})
      // Call does not need to be passed here since it's for call-through.
      : super(origin: origin, voipCall: null);

  ShowedCallThroughSurvey showed() => ShowedCallThroughSurvey(origin: origin);

  /// [voipCall] and [isVoipCallMuted] never get copied.
  @override
  ShowCallThroughSurvey copyWith({
    CallOrigin origin,
    Call voipCall,
    bool isVoipCallMuted,
  }) {
    return ShowCallThroughSurvey(
      origin: origin ?? this.origin,
    );
  }
}

class ShowedCallThroughSurvey extends FinishedCalling {
  const ShowedCallThroughSurvey({
    @required CallOrigin origin,
  }) // Call does not need to be passed here since it's for call-through.
  : super(origin: origin, voipCall: null);
  
  @override
  ShowedCallThroughSurvey copyWith({
    CallOrigin origin,
    Call voipCall,
    bool isVoipCallMuted,
  }) {
    return ShowedCallThroughSurvey(
      origin: origin ?? this.origin,
    );
  }
}

enum CallOrigin {
  incoming,
  dialer,
  recents,
  contacts,
}

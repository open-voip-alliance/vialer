import 'package:equatable/equatable.dart';
import 'package:flutter_phone_lib/flutter_phone_lib.dart';

import '../../../../../domain/calling/call_failure_reason.dart';
import '../../../../../domain/calling/call_through/call_through_exception.dart';

abstract class CallerState extends Equatable {
  const CallerState();

  bool get isInCall => this is! CanCall;

  @override
  List<Object?> get props => [];
}

class NoPermission extends CallerState {
  final bool dontAskAgain;

  const NoPermission({required this.dontAskAgain});

  @override
  List<Object?> get props => [dontAskAgain];
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
  List<Object?> get props => [...super.props, origin];
}

/// Any state that is part of the actual call process:
/// start, during, end, etc.
abstract class CallProcessState extends CallOriginDetermined {
  final CallSessionState? voip;

  Call? get voipCall => voip?.activeCall;

  AudioState? get audioState => voip?.audioState;

  /// Irrelevant (and always false) if [isVoip] is false.
  bool get isVoipCallMuted => audioState?.isMicrophoneMuted ?? false;

  // `voip` is only available when it's a VoIP call.
  bool get isVoip => voip != null;

  bool get isInTransfer =>
      (this is AttendedTransferStarted) || (this is AttendedTransferComplete);

  /// We are currently in a state where we can perform actions on the call,
  /// such as placing it on hold.
  bool get isActionable =>
      this is! InitiatingCallFailed &&
          this is! Ringing &&
          this is! InitiatingCall &&
          !isFinished &&
          !isInTransfer ||
      isMergeable;

  /// We are in a finished state, this means there is no active call
  /// or audio.
  bool get isFinished => this is FinishedCalling;

  bool get isMergeable =>
      isInTransfer && voipCall!.isOnHold ||
      voipCall?.state == CallState.connected;

  const CallProcessState({
    required CallOrigin origin,
    required this.voip,
  }) : super(origin);

  @override
  List<Object?> get props => [
        ...super.props,
        origin,
        voip,
        isVoip,
      ];

  CallProcessState copyWith({
    CallOrigin origin,
    CallSessionState? voip,
  });

  InitiatingCallFailed failed(CallThroughException exception) {
    assert(this is InitiatingCall);

    return InitiatingCallFailed.withException(
      exception,
      origin: origin,
      voip: voip,
    );
  }

  Calling calling({CallSessionState? voip}) => Calling(
        origin: origin,
        voip: voip ?? this.voip,
      );

  FinishedCalling finished({CallSessionState? voip}) => FinishedCalling(
        origin: origin,
        voip: voip ?? this.voip,
      );

  AttendedTransferStarted transferStarted({CallSessionState? voip}) =>
      AttendedTransferStarted(
        origin: origin,
        voip: voip ?? this.voip,
      );

  AttendedTransferComplete transferComplete({CallSessionState? voip}) =>
      AttendedTransferComplete(
        origin: origin,
        voip: voip ?? this.voip,
      );
}

class ShowCallThroughConfirmPage extends CallOriginDetermined
    implements CanCall {
  final String destination;

  const ShowCallThroughConfirmPage({
    required this.destination,
    required CallOrigin origin,
  }) : super(origin);

  @override
  List<Object?> get props => [...super.props, destination];
}

/// Not to be confused with SIP's Ringing method. Because of the layers of
/// abstraction, we only use [Ringing] to indicate that our app is ringing
/// because of an incoming call.
///
/// See [InitiatingCall] for the outgoing equivalent.
class Ringing extends CallProcessState {
  const Ringing({
    required CallSessionState voip,
  }) : super(
          origin: CallOrigin.incoming,
          voip: voip,
        );

  /// [origin] never gets copied (is always [CallOrigin.incoming]).
  @override
  Ringing copyWith({
    CallOrigin? origin,
    CallSessionState? voip,
  }) =>
      Ringing(
        voip: voip ?? this.voip!,
      );
}

class InitiatingCall extends CallProcessState {
  const InitiatingCall({
    required CallOrigin origin,
    CallSessionState? voip,
  }) : super(
          origin: origin,
          voip: voip,
        );

  @override
  InitiatingCall copyWith({
    CallOrigin? origin,
    CallSessionState? voip,
  }) =>
      InitiatingCall(
        origin: origin ?? this.origin,
        voip: voip ?? this.voip,
      );
}

abstract class InitiatingCallFailed extends CallProcessState
    implements CanCall {
  const InitiatingCallFailed._({
    required CallOrigin origin,
    required CallSessionState? voip,
  }) : super(origin: origin, voip: voip);

  factory InitiatingCallFailed.withException(
    Exception exception, {
    required CallOrigin origin,
    required CallSessionState? voip,
  }) =>
      InitiatingCallFailedWithException(
        exception,
        origin: origin,
        voip: voip,
      );

  /// [reason] must not be `unknown`. Use the other constructor if that's the
  /// case.
  factory InitiatingCallFailed.because(
    CallFailureReason reason, {
    required CallOrigin origin,
    required bool isVoip,
  }) =>
      InitiatingCallFailedWithReason(reason, origin: origin, isVoip: isVoip);
}

class InitiatingCallFailedWithException extends InitiatingCallFailed {
  final Exception exception;

  const InitiatingCallFailedWithException(
    this.exception, {
    required CallOrigin origin,
    required CallSessionState? voip,
  }) : super._(origin: origin, voip: voip);

  @override
  List<Object?> get props => [...super.props, exception];

  @override
  InitiatingCallFailedWithException copyWith({
    Exception? exception,
    CallOrigin? origin,
    CallSessionState? voip,
  }) =>
      InitiatingCallFailedWithException(
        exception ?? this.exception,
        origin: origin ?? this.origin,
        voip: voip ?? this.voip,
      );
}

class InitiatingCallFailedWithReason extends InitiatingCallFailed {
  final CallFailureReason reason;

  final bool _isVoip;

  @override
  bool get isVoip => _isVoip;

  const InitiatingCallFailedWithReason(
    this.reason, {
    required CallOrigin origin,
    CallSessionState? voip,
    bool isVoip = false,
  })  : assert(reason != CallFailureReason.unknown),
        _isVoip = voip != null || isVoip,
        super._(origin: origin, voip: voip);

  @override
  List<Object?> get props => [...super.props, reason, _isVoip];

  @override
  InitiatingCallFailedWithReason copyWith({
    CallFailureReason? reason,
    CallOrigin? origin,
    CallSessionState? voip,
  }) =>
      InitiatingCallFailedWithReason(
        reason ?? this.reason,
        origin: origin ?? this.origin,
        voip: voip ?? this.voip,
      );
}

class Calling extends CallProcessState {
  const Calling({
    required CallOrigin origin,
    required CallSessionState? voip,
  }) : super(
          origin: origin,
          voip: voip,
        );

  @override
  Calling copyWith({
    CallOrigin? origin,
    CallSessionState? voip,
  }) =>
      Calling(
        origin: origin ?? this.origin,
        voip: voip ?? this.voip,
      );
}

class AttendedTransferStarted extends CallProcessState {
  const AttendedTransferStarted({
    required CallOrigin origin,
    required CallSessionState? voip,
  }) : super(
          origin: origin,
          voip: voip,
        );

  @override
  AttendedTransferStarted copyWith({
    CallOrigin? origin,
    CallSessionState? voip,
  }) =>
      AttendedTransferStarted(
        origin: origin ?? this.origin,
        voip: voip ?? this.voip,
      );
}

class FinishedCalling extends CallProcessState implements CanCall {
  const FinishedCalling({
    required CallOrigin origin,
    CallSessionState? voip,
  }) : super(
          origin: origin,
          voip: voip,
        );

  @override
  FinishedCalling copyWith({
    CallOrigin? origin,
    CallSessionState? voip,
  }) =>
      FinishedCalling(
        origin: origin ?? this.origin,
        voip: voip ?? this.voip,
      );
}

class AttendedTransferComplete extends FinishedCalling {
  const AttendedTransferComplete({
    required CallOrigin origin,
    CallSessionState? voip,
  }) : super(
          origin: origin,
          voip: voip,
        );

  @override
  AttendedTransferComplete copyWith({
    CallOrigin? origin,
    CallSessionState? voip,
  }) =>
      AttendedTransferComplete(
        origin: origin ?? this.origin,
        voip: voip ?? this.voip,
      );
}

enum CallOrigin {
  incoming,
  dialer,
  recents,
  contacts,
  unknown,
}

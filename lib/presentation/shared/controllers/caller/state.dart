// We can safely ignore this, because we use Equatable.
// ignore_for_file: avoid_implementing_value_types

import 'package:equatable/equatable.dart';
import 'package:flutter_phone_lib/flutter_phone_lib.dart';

import '../../../../../data/models/calling/call_failure_reason.dart';
import '../../../../../data/models/calling/call_through/call_through_exception.dart';

abstract class CallerState extends Equatable {
  const CallerState();

  bool get isInCall => this is! CanCall;

  @override
  List<Object?> get props => [];
}

class NoPermission extends CallerState {
  const NoPermission({required this.dontAskAgain});

  final bool dontAskAgain;

  @override
  List<Object?> get props => [dontAskAgain];
}

class PreparingCall extends CallerState {
  const PreparingCall();
}

class CanCall extends CallerState {
  const CanCall();
}

/// Used only to pass the [origin] to future states.
class CallOriginDetermined extends CallerState {
  const CallOriginDetermined(this.origin);

  /// Where the call started in the UI: dialer, recents, contacts, etc.
  /// Can be null if it's an incoming call.
  final CallOrigin origin;

  @override
  List<Object?> get props => [...super.props, origin];
}

/// Any state that is part of the actual call process:
/// start, during, end, etc.
abstract class CallProcessState extends CallOriginDetermined {
  const CallProcessState({
    required CallOrigin origin,
    required this.voip,
    this.isTransferAborted = false,
  }) : super(origin);
  final CallSessionState? voip;

  Call? get voipCall => voip?.activeCall;

  AudioState? get audioState => voip?.audioState;

  /// Irrelevant (and always false) if [isVoip] is false.
  bool get isVoipCallMuted => audioState?.isMicrophoneMuted ?? false;

  // `voip` is only available when it's a VoIP call.
  bool get isVoip => voip != null;

  bool get isInTransfer =>
      (this is AttendedTransferStarted) || (this is AttendedTransferComplete);

  final bool isTransferAborted;

  /// We are currently in a state where we can perform actions on the call,
  /// such as placing it on hold.
  bool get isActionable =>
      this is! StartingCallFailed &&
          this is! Ringing &&
          this is! StartingCall &&
          !isFinished &&
          !isInTransfer ||
      isMergeable;

  /// We are in a finished state, this means there is no active call
  /// or audio.
  bool get isFinished => this is FinishedCalling;

  bool get isMergeable =>
      isInTransfer && voipCall!.isOnHold ||
      voipCall?.state == CallState.connected;

  bool get isInBadQualityCall =>
      voipCall!.hasValidMosValue &&
      voipCall!.currentMos < BAD_CALL_QUALITY_MOS_THRESHOLD;

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

  StartingCallFailed failed(CallThroughException exception) {
    assert(this is StartingCall, 'current state must be StartingCall');

    return StartingCallFailed.withException(
      exception,
      origin: origin,
      voip: voip,
    );
  }

  Calling calling({CallSessionState? voip, bool? isTransferAborted}) => Calling(
        origin: origin,
        voip: voip ?? this.voip,
        isTransferAborted: isTransferAborted ?? false,
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
  const ShowCallThroughConfirmPage({
    required this.destination,
    required CallOrigin origin,
  }) : super(origin);
  final String destination;

  @override
  List<Object?> get props => [...super.props, destination];
}

/// Not to be confused with SIP's Ringing method. Because of the layers of
/// abstraction, we only use [Ringing] to indicate that our app is ringing
/// because of an incoming call.
///
/// See [StartingCall] for the outgoing equivalent.
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

class StartingCall extends CallProcessState {
  const StartingCall({
    required super.origin,
    super.voip,
  });

  @override
  StartingCall copyWith({
    CallOrigin? origin,
    CallSessionState? voip,
  }) =>
      StartingCall(
        origin: origin ?? this.origin,
        voip: voip ?? this.voip,
      );
}

abstract class StartingCallFailed extends CallProcessState implements CanCall {
  const StartingCallFailed._({
    required super.origin,
    required super.voip,
  });

  factory StartingCallFailed.withException(
    Exception exception, {
    required CallOrigin origin,
    required CallSessionState? voip,
  }) =>
      StartingCallFailedWithException(
        exception,
        origin: origin,
        voip: voip,
      );

  /// [reason] must not be `unknown`. Use the other constructor if that's the
  /// case.
  factory StartingCallFailed.because(
    CallFailureReason reason, {
    required CallOrigin origin,
    required bool isVoip,
  }) =>
      StartingCallFailedWithReason(reason, origin: origin, isVoip: isVoip);
}

class StartingCallFailedWithException extends StartingCallFailed {
  const StartingCallFailedWithException(
    this.exception, {
    required super.origin,
    required super.voip,
  }) : super._();
  final Exception exception;

  @override
  List<Object?> get props => [...super.props, exception];

  @override
  StartingCallFailedWithException copyWith({
    Exception? exception,
    CallOrigin? origin,
    CallSessionState? voip,
  }) =>
      StartingCallFailedWithException(
        exception ?? this.exception,
        origin: origin ?? this.origin,
        voip: voip ?? this.voip,
      );
}

class StartingCallFailedWithReason extends StartingCallFailed {
  const StartingCallFailedWithReason(
    this.reason, {
    required super.origin,
    super.voip,
    bool isVoip = false,
  })  : assert(reason != CallFailureReason.unknown, 'reason must be known'),
        _isVoip = voip != null || isVoip,
        super._();
  final CallFailureReason reason;

  final bool _isVoip;

  @override
  bool get isVoip => _isVoip;

  @override
  List<Object?> get props => [...super.props, reason, _isVoip];

  @override
  StartingCallFailedWithReason copyWith({
    CallFailureReason? reason,
    CallOrigin? origin,
    CallSessionState? voip,
  }) =>
      StartingCallFailedWithReason(
        reason ?? this.reason,
        origin: origin ?? this.origin,
        voip: voip ?? this.voip,
      );
}

class Calling extends CallProcessState {
  const Calling({
    required super.origin,
    required super.voip,
    super.isTransferAborted = false,
  });

  @override
  Calling copyWith({
    CallOrigin? origin,
    CallSessionState? voip,
    bool? isTransferAborted,
  }) =>
      Calling(
        origin: origin ?? this.origin,
        voip: voip ?? this.voip,
        isTransferAborted: isTransferAborted ?? false,
      );
}

class AttendedTransferStarted extends CallProcessState {
  const AttendedTransferStarted({
    required super.origin,
    required super.voip,
  });

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
    required super.origin,
    super.voip,
  });

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
    required super.origin,
    super.voip,
  });

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
  sharedContacts,
  colleagues,
  unknown,
}

/// The threshold below which we consider a call to be of bad quality.
const BAD_CALL_QUALITY_MOS_THRESHOLD = 2;

/// A call must be below [BAD_CALL_QUALITY_MOS_THRESHOLD] for this many seconds
/// before it will be considered a bad quality call.
const BAD_CALL_QUALITY_MIN_DURATION = 5;

extension on Call? {
  bool get hasValidMosValue =>
      this != null && this!.currentMos > 0 && this!.duration >= 2;
}

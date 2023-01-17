import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:dartx/dartx.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phone_lib/flutter_phone_lib.dart' hide Reason;
import 'package:flutter_phone_lib/flutter_phone_lib.dart' as fpl;

import '../../../../../dependency_locator.dart';
import '../../../../../domain/authentication/is_authenticated.dart';
import '../../../../../domain/calling/call.dart';
import '../../../../../domain/calling/call_failure_reason.dart';
import '../../../../../domain/calling/call_through/call_through_exception.dart';
import '../../../../../domain/calling/voip/answer_voip_call.dart';
import '../../../../../domain/calling/voip/begin_transfer.dart';
import '../../../../../domain/calling/voip/end.dart';
import '../../../../../domain/calling/voip/get_call_session_state.dart';
import '../../../../../domain/calling/voip/get_has_voip_enabled.dart';
import '../../../../../domain/calling/voip/get_has_voip_started.dart';
import '../../../../../domain/calling/voip/get_voip_call_event_stream.dart';
import '../../../../../domain/calling/voip/hold.dart';
import '../../../../../domain/calling/voip/launch_ios_audio_route_picker.dart';
import '../../../../../domain/calling/voip/merge_transfer.dart';
import '../../../../../domain/calling/voip/rate_voip_call.dart';
import '../../../../../domain/calling/voip/route_audio.dart';
import '../../../../../domain/calling/voip/route_audio_to_bluetooth_device.dart';
import '../../../../../domain/calling/voip/send_voip_dtmf.dart';
import '../../../../../domain/calling/voip/start_voip.dart';
import '../../../../../domain/calling/voip/toggle_hold.dart';
import '../../../../../domain/calling/voip/toggle_mute.dart';
import '../../../../../domain/calling/voip/voip_not_allowed.dart';
import '../../../../../domain/feedback/call_problem.dart';
import '../../../../../domain/feedback/increment_app_rating_survey_action_count.dart';
import '../../../../../domain/legacy/storage.dart';
import '../../../../../domain/metrics/track_call_initiated.dart';
import '../../../../../domain/metrics/track_call_through_call.dart';
import '../../../../../domain/metrics/track_outbound_call_failed.dart';
import '../../../../../domain/metrics/track_user_initiated_outbound_call.dart';
import '../../../../../domain/metrics/track_voip_call.dart';
import '../../../../../domain/onboarding/request_permission.dart';
import '../../../../../domain/user/connectivity/connectivity_type.dart';
import '../../../../../domain/user/connectivity/get_current_connectivity_status.dart';
import '../../../../../domain/user/get_logged_in_user.dart';
import '../../../../../domain/user/get_permission_status.dart';
import '../../../../../domain/user/permissions/permission.dart';
import '../../../../../domain/user/permissions/permission_status.dart';
import '../../../../../domain/user/settings/app_setting.dart';
import '../../../../../domain/user/settings/open_settings.dart';
import '../../../../util/loggable.dart';
import 'state.dart' hide AttendedTransferStarted;

export 'state.dart';

class CallerCubit extends Cubit<CallerState> with Loggable {
  final _isAuthenticated = IsAuthenticated();
  final _getConnectivityType = GetCurrentConnectivityTypeUseCase();

  final _getUser = GetLoggedInUserUseCase();

  final _storageRepository = dependencyLocator<StorageRepository>();

  final _call = CallUseCase();
  final _trackVoipCall = TrackVoipCallUseCase();
  final _trackCallThroughCall = TrackCallThroughCallUseCase();
  final _trackVoipCallStarted = TrackVoipCallStartedUseCase();
  final _trackOutboundCallFailed = TrackOutboundCallFailedUseCase();
  final _trackUserInitiatedOutboundCall = TrackUserInitiatedOutboundCall();

  final _getPermissionStatus = GetPermissionStatusUseCase();
  final _requestPermission = RequestPermissionUseCase();
  final _openAppSettings = OpenSettingsAppUseCase();

  final _getHasVoipEnabled = GetHasVoipEnabledUseCase();
  final _hasVoipStarted = GetHasVoipStartedUseCase();
  final _startVoip = StartVoipUseCase();
  final _getVoipCallEventStream = GetVoipCallEventStreamUseCase();
  final _answerVoipCall = AnswerVoipCallUseCase();
  final _getCallSessionState = GetCallSessionState();
  final _toggleMuteVoipCall = ToggleMuteVoipCallUseCase();
  final _toggleHoldVoipCall = ToggleHoldVoipCallUseCase();
  final _holdVoipCall = HoldVoipCallUseCase();
  final _sendVoipDtmf = SendVoipDtmfUseCase();
  final _endVoipCall = EndVoipCallUseCase();
  final _rateVoipCall = RateVoipCallUseCase();
  final _routeAudio = RouteAudioUseCase();
  final _launchIOSAudioRoutePicker = LaunchIOSAudioRoutePickerUseCase();
  final _routeAudioToBluetoothDevice = RouteAudioToBluetoothDeviceUseCase();
  final _beginTransfer = BeginTransferUseCase();
  final _mergeTransfer = MergeTransferUseCase();

  final _incrementAppRatingActionCount =
      IncrementAppRatingSurveyActionCountUseCase();

  _PreservedCallSessionState _preservedCallSessionState =
      _PreservedCallSessionState();

  // For VoIP.
  StreamSubscription? _voipCallEventSubscription;

  CallerCubit() : super(const CanCall()) {
    if (_isAuthenticated()) {
      initialize();
    }

    _hasVoipStarted().then(
      (_) {
        // We can still do these things, even if VoIP failed to start.
        checkPhonePermission();
        _voipCallEventSubscription ??=
            _getVoipCallEventStream().listen(_onVoipCallEvent);
      },
    );
  }

  void initialize() {
    checkPhonePermission();
    _startVoipIfNecessary();
  }

  Future<void> _startVoipIfNecessary() async {
    if (!(await _getHasVoipEnabled())) return;

    try {
      await _startVoip();

      // We need to go to the incoming/ongoing call screen if we were opened by the
      // notification.
      final voip = await _getCallSessionState();
      final activeCall = voip.activeCall;

      if (activeCall != null &&
          activeCall.direction.isInbound &&
          activeCall.state != CallState.ended) {
        if (activeCall.state == CallState.initializing) {
          emit(Ringing(voip: voip));
        } else {
          _trackVoipCallStarted(
            via: CallOrigin.incoming.toTrackString(),
            direction: CallDirection.inbound,
          );

          emit(Calling(origin: CallOrigin.incoming, voip: voip));
        }
      }
    } on VoipNotAllowedException {}
  }

  Future<void> call(
    String destination, {
    required CallOrigin origin,
    bool showingConfirmPage = false,
  }) async {
    final callViaVoip = await _getHasVoipEnabled();

    if (callViaVoip) {
      _trackUserInitiatedOutboundCall(
        via: origin.toTrackString(),
        isVoip: callViaVoip,
        type: destination == '*8' ? CallType.pickupGroup : CallType.standard,
      );
    }

    if (state is! CanCall) {
      logger.severe(
        'Unable to place outgoing call, call state: ${state.runtimeType}',
      );
      _trackOutboundCallFailed(
        reason: CallFailureReason.invalidCallState,
        message: state.runtimeType.toString(),
        isVoip: callViaVoip,
      );
      return;
    }

    if (callViaVoip) {
      await _callViaVoip(destination, origin: origin);
    } else {
      await _callViaCallThrough(
        destination,
        origin: origin,
        showingConfirmPage: showingConfirmPage,
      );
    }
  }

  Future<bool> _hasMicPermission() async {
    final permissionStatus = await _requestPermission(
      permission: Permission.microphone,
    );

    final granted = permissionStatus == PermissionStatus.granted;

    if (!granted) {
      logger.info('Microphone permission is denied, stopping/ignoring call');
    }

    return granted;
  }

  Future<void> answerVoipCall() async {
    if (!await _hasMicPermission()) return;

    await _answerVoipCall();
  }

  Future<void> rateVoipCall({
    required CallFeedbackResult result,
    required Call call,
  }) async =>
      await _rateVoipCall(
        feedback: result,
        usedRoutes: _preservedCallSessionState.usedAudioRoutes,
        mos: _preservedCallSessionState.mos,
        call: call,
      );

  Future<void> _callViaCallThrough(
    String destination, {
    required CallOrigin origin,
    bool showingConfirmPage = false,
  }) async {
    final shouldShowConfirmPage =
        _getUser().settings.get(AppSetting.showDialerConfirmPopup) &&
            !showingConfirmPage;

    // First request to allow to make phone calls,
    // otherwise don't show the call-through page at all.
    if (Platform.isAndroid) {
      // Requesting already allowed permissions won't reshow the dialog.
      final status = await _requestPhonePermission();

      if (status == PermissionStatus.denied ||
          status == PermissionStatus.permanentlyDenied) {
        _updateWhetherCanCall(status);
        return;
      }
    }

    if (shouldShowConfirmPage) {
      logger.info('Going to call-through page');

      emit(
        ShowCallThroughConfirmPage(
          destination: destination,
          origin: origin,
        ),
      );
    } else {
      try {
        _trackCallThroughCall(
          via: origin.toTrackString(),
          direction: CallDirection.outbound,
        );

        emit(InitiatingCall(origin: origin));
        logger.info('Initiating call-through call');
        await _call(destination: destination, useVoip: false);
        emit(processState.calling());
      } on CallThroughException catch (e) {
        emit(processState.failed(e));
      }
    }
  }

  Future<void> _callViaVoip(
    String destination, {
    required CallOrigin origin,
  }) async {
    if (!await _hasMicPermission()) {
      _trackOutboundCallFailed(
        reason: CallFailureReason.noMicrophonePermission,
      );
      logger.warning(
        'Outbound VoIP call failed: No mic permission',
      );
      return;
    }

    if (await _getConnectivityType() == ConnectivityType.none) {
      _trackOutboundCallFailed(reason: CallFailureReason.noConnectivity);
      logger.warning(
        'Outbound VoIP call failed: No internet connection',
      );
      return;
    }

    logger.info('Starting VoIP call');
    try {
      _trackVoipCallStarted(
        via: origin.toTrackString(),
        direction: CallDirection.outbound,
      );

      emit(CallOriginDetermined(origin));
      await _call(destination: destination, useVoip: true);

      // When using VoIP, we emit states in _onCallEvent. That's why we don't
      // emit them here like in _callViaCallThrough.

      // TODO: on VoipException
    } on CallThroughException catch (e) {
      _trackOutboundCallFailed(
        reason: CallFailureReason.unknown,
        message: e.runtimeType.toString(),
      );
      emit(processState.failed(e));
    }
  }

  Future<void> _onVoipCallEvent(Event event) async {
    // Immediately grab the state so we don't run into the situation
    // where it could change during execution.
    final state = this.state;

    if (!_shouldHandleVoipCallEvent(state, event)) {
      return;
    }

    if (event is CallSetupFailedEvent) {
      _handleCallSetupFailedEvent(state, event);
      return;
    }

    final callSessionState = (event as CallSessionEvent).state!;

    // We will immediately handle any setup call events to make sure these are
    // always emitted.
    if (event is IncomingCallReceived || event is OutgoingCallStarted) {
      _handleCallSetupEvent(state, event, callSessionState);
      return;
    }

    // When we have reached a state where the call session is finished, we do
    // not want to continue updating the UI further as we may no longer
    // get call objects.
    if (state is FinishedCalling) {
      logger.info('State is call ended, not updating state any further');
      return;
    }

    _preserve(callSessionState);

    // Call events happened too fast, it's possible we are not in a
    // CallProcessState yet, so try to recover.
    if (state is! CallProcessState) {
      return _attemptToRecoverFromMissedEvent(state, event, callSessionState);
    }

    if (event is CallConnected) {
      _preservedCallSessionState = _PreservedCallSessionState();
      emit(state.calling(voip: callSessionState));
      logger.info('VoIP call connected');
    } else if (event is AttendedTransferStarted) {
      emit(state.transferStarted(voip: callSessionState));
      logger.info('VoIP attended transfer started');
    } else if (event is AttendedTransferAborted) {
      emit(state.calling(voip: callSessionState));
      logger.info('VoIP attended transfer aborted');
    } else if (event is AttendedTransferEnded) {
      emit(state.transferComplete(voip: callSessionState));
      logger.info('VoIP attended transfer completed');
    } else if (event is CallEnded) {
      emit(state.finished(voip: callSessionState));
      _trackVoipCallEvent(callSessionState);
      _incrementAppRatingActionCount();
      logger.info('VoIP call ended');
    } else {
      emit(state.copyWith(voip: callSessionState));
    }
  }

  bool _shouldHandleVoipCallEvent(CallerState state, Event event) {
    if (state is CallProcessState) {
      final isVoip = state.isVoip;

      if (!isVoip) {
        logger.info(
          'Ignoring VoIP event because we\'re in a call-through call',
        );
        return false;
      }
    }

    if (event is! CallSetupFailedEvent && event is! CallSessionEvent) {
      logger.info(
        'Ignoring event as it is not a'
        ' CallSessionEvent or CallSetupFailedEvent',
      );
      return false;
    }

    return true;
  }

  /// If we miss a VoIP event our cubit state might not be in-line with the
  /// VoIP state. So we'll try to recover by getting it caught up.
  void _attemptToRecoverFromMissedEvent(
    CallerState state,
    Event event,
    CallSessionState callSessionState,
  ) {
    // If the event is [CallEnded] then we don't want to do anything further,
    // we just want to get the state back to [CanCall] so future calls
    // will be possible.
    if (event is CallEnded || callSessionState.activeCall == null) {
      logger.info('VoIP call ended (recovered)');

      if (state is CanCall) return;

      // The state here shouldn't ever be [CallProcessState] if we are trying
      // to recover, but we'll add it to make it more robust if the method
      // is called from somewhere it probably shouldn't be.
      if (state is CallProcessState) {
        emit(state.finished(voip: callSessionState));
      } else {
        emit(const CanCall());
      }

      return;
    }

    // We should always be in a [CallOriginDetermined] state, but so we can
    // track if this does happen we'll add a special origin.
    final origin =
        state is CallOriginDetermined ? state.origin : CallOrigin.unknown;

    emit(Calling(origin: origin, voip: callSessionState));

    logger.info('VoIP call connected (recovered)');
  }

  void _trackVoipCallEvent(CallSessionState callSessionState) => _trackVoipCall(
        direction:
            callSessionState.activeCall?.direction == CallDirection.inbound
                ? CallDirection.inbound
                : CallDirection.outbound,
        usedRoutes: _preservedCallSessionState.usedAudioRoutes,
        usedBluetoothDevices: _preservedCallSessionState.usedBluetoothDevices,
        mos: _preservedCallSessionState.mos,
        reason: callSessionState.activeCall?.reason,
      );

  void _handleCallSetupEvent(
    CallerState state,
    Event event,
    CallSessionState callSessionState,
  ) {
    if (event is IncomingCallReceived) {
      _trackVoipCallStarted(
        via: CallOrigin.incoming.toTrackString(),
        direction: CallDirection.inbound,
      );

      emit(Ringing(voip: callSessionState));

      logger.info('Incoming VoIP call, ringing');
    } else if (event is OutgoingCallStarted) {
      emit(
        InitiatingCall(
          origin:
              state is CallOriginDetermined ? state.origin : CallOrigin.unknown,
          voip: callSessionState,
        ),
      );
      logger.info('Initiating VoIP call');
    }
  }

  void _handleCallSetupFailedEvent(
    CallerState state,
    CallSetupFailedEvent event,
  ) {
    final reason = event.reason.toDomainEntity();
    String direction;
    if (event is OutgoingCallSetupFailed) {
      direction = 'Outgoing';
      _trackOutboundCallFailed(reason: reason);
    } else if (event is IncomingCallSetupFailed) {
      direction = 'Incoming';
    } else {
      direction = 'Unknown';
    }

    logger.warning(
      '$direction call setup failed, reason: ${reason.name}',
    );

    emit(
      InitiatingCallFailed.because(
        reason,
        origin: (state as CallOriginDetermined).origin,
        isVoip: true,
      ),
    );
  }

  void _preserve(CallSessionState callSessionState) =>
      _preservedCallSessionState.preserve(callSessionState);

  Future<void> toggleMute() async => await _toggleMuteVoipCall();

  Future<void> beginTransfer(String number) => _beginTransfer(number: number);

  Future<void> mergeTransfer() => _mergeTransfer();

  Future<void> toggleHoldVoipCall() => _toggleHoldVoipCall();

  Future<void> holdVoipCall() => _holdVoipCall();

  Future<void> sendVoipDtmf(String dtmf) => _sendVoipDtmf(dtmf: dtmf);

  Future<void> endVoipCall() => _endVoipCall();

  Future<void> routeAudio(AudioRoute route) => _routeAudio(route: route);

  Future<void> launchIOSAudioRoutePicker() => _launchIOSAudioRoutePicker();

  Future<void> routeAudioToBluetoothDevice(BluetoothAudioRoute route) =>
      _routeAudioToBluetoothDevice(route: route);

  void notifyCanCall() {
    // Necessary for auto cast.
    final state = this.state;

    // Ignored for VoIP calls.
    if (state is CallProcessState && state.isVoip) {
      return;
    }

    if (state is Calling) {
      emit(state.finished());
      logger.info('Call-through call ended');
    } else if (state is! NoPermission) {
      emit(const CanCall());
    } else {
      checkPhonePermission();
    }
  }

  /// For when you're sure the current state is a [CallProcessState].
  CallProcessState get processState => state as CallProcessState;

  @override
  Future<void> close() async {
    await _voipCallEventSubscription?.cancel();
    await super.close();
  }

  Future<PermissionStatus> _requestPhonePermission() {
    return _requestPermission(permission: Permission.phone);
  }

  Future<void> requestPermission() async {
    final status = await _requestPhonePermission();

    _updateWhetherCanCall(status);
  }

  Future<void> checkPhonePermission() async {
    if (Platform.isAndroid) {
      final status = await _getPermissionStatus(permission: Permission.phone);
      _updateWhetherCanCall(status);
    }
  }

  void _updateWhetherCanCall(PermissionStatus status) {
    // We don't want to interrupt an ongoing call.
    if (state is CallProcessState) return;

    if (status == PermissionStatus.granted) {
      emit(const CanCall());
    } else {
      emit(
        NoPermission(
          dontAskAgain: status == PermissionStatus.permanentlyDenied,
        ),
      );
    }
  }

  void openAppSettings() async {
    await _openAppSettings();
  }

  /// The minimum duration after a call rating has been submitted before we
  /// request another.
  static const _durationBetweenCallRatings = Duration(days: 7);

  /// We will only ask for a call rating on this percentage of calls.
  static const _percentageChanceOfAskingForCallRating = 15;

  /// Determine whether or not we should prompt the user for a call rating, this
  /// is partially random with a minimum duration between requests.
  bool shouldRequestCallRating() {
    if (Random().nextInt(100) > _percentageChanceOfAskingForCallRating) {
      return false;
    }

    final isCallRatingDue =
        _storageRepository.lastCallRatingAskedTime?.isBefore(
              DateTime.now().subtract(_durationBetweenCallRatings),
            ) ??
            true;

    if (!isCallRatingDue) return false;

    _storageRepository.lastCallRatingAskedTime = DateTime.now();
    return true;
  }
}

extension on CallOrigin {
  String toTrackString() {
    switch (this) {
      case CallOrigin.incoming:
        return 'incoming';
      case CallOrigin.dialer:
        return 'dialer';
      case CallOrigin.recents:
        return 'recent';
      case CallOrigin.contacts:
        return 'contact';
      case CallOrigin.colleagues:
        return 'colleague';
      case CallOrigin.unknown:
        return 'unknown';
    }
  }
}

/// There are certain values that will be provided throughout the duration of
/// a call session that need to be tracked so they can be reported at the
/// end of a call. This object will hold those values.
class _PreservedCallSessionState {
  var _mos = 0.0;

  double get mos => _mos;

  final usedBluetoothDevices = <String>{};
  final usedAudioRoutes = <AudioRoute>{};

  void preserve(CallSessionState state) {
    usedAudioRoutes.add(state.audioState.currentRoute);

    final bluetoothDeviceName = state.audioState.bluetoothDeviceName;

    if (bluetoothDeviceName != null && !bluetoothDeviceName.isBlank) {
      usedBluetoothDevices.add(bluetoothDeviceName);
    }

    if (state.activeCall != null) {
      final mos = state.activeCall?.mos ?? 0.0;

      if (mos > 0.0) {
        _mos = mos;
      }
    }
  }
}

extension on fpl.Reason {
  CallFailureReason toDomainEntity() {
    if (this == fpl.Reason.inCall) {
      return CallFailureReason.inCall;
    } else if (this == fpl.Reason.rejectedByAndroidTelecomFramework) {
      return CallFailureReason.rejectedByAndroidTelecomFramework;
    } else if (this == fpl.Reason.unableToRegister) {
      return CallFailureReason.unableToRegister;
    } else if (this == fpl.Reason.rejectedByCallKit) {
      return CallFailureReason.rejectedByCallKit;
    } else {
      throw UnsupportedError('Unsupported fpl.Reason: $this');
    }
  }
}

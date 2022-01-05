import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phone_lib/audio/bluetooth_audio_route.dart';
import 'package:flutter_phone_lib/call_session_state.dart';
import 'package:flutter_phone_lib/flutter_phone_lib.dart';

import '../../../../../domain/connectivity_type.dart';
import '../../../../../domain/entities/call_problem.dart';
import '../../../../../domain/entities/exceptions/call_through.dart';
import '../../../../../domain/entities/exceptions/voip_not_allowed.dart';
import '../../../../../domain/entities/permission.dart';
import '../../../../../domain/entities/permission_status.dart';
import '../../../../../domain/entities/setting.dart';
import '../../../../../domain/entities/survey/survey_trigger.dart';
import '../../../../../domain/usecases/answer_voip_call.dart';
import '../../../../../domain/usecases/call/call.dart';
import '../../../../../domain/usecases/call/voip/begin_transfer.dart';
import '../../../../../domain/usecases/call/voip/end.dart';
import '../../../../../domain/usecases/call/voip/get_call_session_state.dart';
import '../../../../../domain/usecases/call/voip/hold.dart';
import '../../../../../domain/usecases/call/voip/launch_ios_audio_route_picker.dart';
import '../../../../../domain/usecases/call/voip/merge_transfer.dart';
import '../../../../../domain/usecases/call/voip/rate_voip_call.dart';
import '../../../../../domain/usecases/call/voip/route_audio.dart';
import '../../../../../domain/usecases/call/voip/route_audio_to_bluetooth_device.dart';
import '../../../../../domain/usecases/call/voip/toggle_hold.dart';
import '../../../../../domain/usecases/call/voip/toggle_mute.dart';
import '../../../../../domain/usecases/change_setting.dart';
import '../../../../../domain/usecases/get_call_through_calls_count.dart';
import '../../../../../domain/usecases/get_current_connectivity_status.dart';
import '../../../../../domain/usecases/get_has_voip_enabled.dart';
import '../../../../../domain/usecases/get_has_voip_started.dart';
import '../../../../../domain/usecases/get_is_authenticated.dart';
import '../../../../../domain/usecases/get_permission_status.dart';
import '../../../../../domain/usecases/get_setting.dart';
import '../../../../../domain/usecases/get_voip_call_event_stream.dart';
import '../../../../../domain/usecases/increment_call_through_calls_count.dart';
import '../../../../../domain/usecases/metrics/track_call_initiated.dart';
import '../../../../../domain/usecases/metrics/track_call_through_call.dart';
import '../../../../../domain/usecases/metrics/track_voip_call.dart';
import '../../../../../domain/usecases/onboarding/request_permission.dart';
import '../../../../../domain/usecases/open_settings.dart';
import '../../../../../domain/usecases/send_voip_dtmf.dart';
import '../../../../../domain/usecases/start_voip.dart';
import '../../../../util/loggable.dart';
import 'state.dart' hide AttendedTransferStarted;

export 'state.dart';

class CallerCubit extends Cubit<CallerState> with Loggable {
  final _isAuthenticated = GetIsAuthenticatedUseCase();
  final _getConnectivityType = GetCurrentConnectivityTypeUseCase();

  final _getShowDialerConfirmPopUpSetting =
      GetSettingUseCase<ShowDialerConfirmPopupSetting>();
  final _getShowSurveyDialogSetting =
      GetSettingUseCase<ShowSurveyDialogSetting>();
  final _changeSetting = ChangeSettingUseCase();

  final _call = CallUseCase();
  final _getCallThroughCallsCount = GetCallThroughCallsCountUseCase();
  final _trackVoipCall = TrackVoipCallUseCase();
  final _trackCallThroughCall = TrackCallThroughCallUseCase();
  final _trackVoipCallStarted = TrackVoipCallStartedUseCase();

  final _incrementCallThroughCallsCount =
      IncrementCallThroughCallsCountUseCase();
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

  Timer? _callThroughTimer;

  _PreservedCallSessionState _preservedCallSessionState =
      _PreservedCallSessionState();

  // For VoIP.
  StreamSubscription? _voipCallEventSubscription;

  CallerCubit() : super(const CanCall()) {
    _isAuthenticated().then((isAuthenticated) {
      if (isAuthenticated) {
        initialize();
      }
    });

    _hasVoipStarted().then(
      (_) {
        checkCallPermissionIfNotVoip();
        _voipCallEventSubscription ??=
            _getVoipCallEventStream().listen(_onVoipCallEvent);
      },
    );
  }

  void initialize() {
    checkCallPermissionIfNotVoip();
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
    if (state is! CanCall) return;

    if (await _getHasVoipEnabled()) {
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
    final shouldShowConfirmPage = await _getShowDialerConfirmPopUpSetting()
            .then((setting) => setting.value) &&
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

        _callThroughTimer = Timer(
          AfterThreeCallThroughCallsTrigger.minimumCallDuration,
          () async {
            if (state is Calling) {
              _incrementCallThroughCallsCount();

              final showSurvey = await _getShowSurveyDialogSetting()
                  .then((setting) => setting.value);

              const callTriggerCount =
                  AfterThreeCallThroughCallsTrigger.callCount;
              const callTriggerIgnoreCount =
                  AfterThreeCallThroughCallsTrigger.ignoreCallCount;

              final count = _getCallThroughCallsCount();
              if (showSurvey && count >= callTriggerCount) {
                // At 6 calls, we set "Don't show this again"
                // to true by default. This means that after dismissing the
                // survey for 3 times, the survey will be shown one last time
                // with "Don't show this again" enabled by default. So if they
                // dismiss again, it won't be shown anymore.
                if (count == callTriggerIgnoreCount) {
                  await _changeSetting(
                    setting: const ShowSurveyDialogSetting(false),
                  );
                }

                emit(processState.showCallThroughSurvey());
              }
            }
          },
        );
      } on CallThroughException catch (e) {
        emit(processState.failed(e));
      }
    }
  }

  Future<void> _callViaVoip(
    String destination, {
    required CallOrigin origin,
  }) async {
    if (!await _hasMicPermission()) return;

    if (await _getConnectivityType() == ConnectivityType.none) return;

    logger.info('Starting VoIP call');
    try {
      _trackVoipCallStarted(
        via: origin.toTrackString(),
        direction: CallDirection.outbound,
      );

      await _call(destination: destination, useVoip: true);
      emit(CallOriginDetermined(origin));

      // When using VoIP, we emit states in _onCallEvent. That's why we don't
      // emit them here like in _callViaCallThrough.

      // TODO: on VoipException
    } on CallThroughException catch (e) {
      emit(processState.failed(e));
    }
  }

  Future<void> _onVoipCallEvent(Event event) async {
    if (state is CallProcessState) {
      final isVoip = (state as CallProcessState).isVoip;

      if (!isVoip) {
        logger.info(
          'Ignoring VoIP event because we\'re in a call-through call',
        );
        return;
      }
    }

    // The call UI isn't interested in any non-call-session-events.
    if (event is! CallSessionEvent) {
      logger.info('Ignoring event as it is not a CallSessionEvent');
      return;
    }

    final callSessionState = event.state!;

    // We will immediately handle any setup call events to make sure these are
    // always emitted.
    if (event is IncomingCallReceived) {
      _trackVoipCallStarted(
        via: CallOrigin.incoming.toTrackString(),
        direction: CallDirection.inbound,
      );

      emit(Ringing(voip: callSessionState));

      logger.info('Incoming VoIP call, ringing');
      return;
    } else if (event is OutgoingCallStarted) {
      final originState = state as CallOriginDetermined;
      emit(InitiatingCall(origin: originState.origin, voip: callSessionState));
      logger.info('Initiating VoIP call');
      return;
    }

    // When we have reached a state where the call session is finished, we do
    // not want to continue updating the UI further as we may no longer
    // get call objects.
    if (state is FinishedCalling) {
      logger.info('State is call ended, not updating state any further');
      return;
    }

    if (state is CallProcessState) {
      if (event is CallConnected) {
        _preservedCallSessionState = _PreservedCallSessionState();
        emit(processState.calling(voip: callSessionState));
        logger.info('VoIP call connected');
      } else if (event is AttendedTransferStarted) {
        emit(processState.transferStarted(voip: callSessionState));
        logger.info('VoIP attended transfer started');
      } else if (event is AttendedTransferAborted) {
        emit(processState.calling(voip: callSessionState));
        logger.info('VoIP attended transfer aborted');
      } else if (event is AttendedTransferEnded) {
        emit(processState.transferComplete(voip: callSessionState));
        logger.info('VoIP attended transfer completed');
      } else if (event is CallEnded) {
        emit(processState.finished(voip: callSessionState));

        _trackVoipCall(
          direction:
              callSessionState.activeCall?.direction == CallDirection.inbound
                  ? CallDirection.inbound
                  : CallDirection.outbound,
          usedRoutes: _preservedCallSessionState.usedAudioRoutes,
          mos: _preservedCallSessionState.mos,
          reason: callSessionState.activeCall?.reason,
        );

        logger.info('VoIP call ended');
      }
    } else {
      // Call events happened too fast, it's possible we are not in
      // a CallProcessState yet, so try to recover.

      if (event is CallConnected || callSessionState.activeCall != null) {
        final originState = state as CallOriginDetermined;
        emit(
          Calling(
            origin: originState.origin,
            voip: callSessionState,
          ),
        );
        logger.info('VoIP call connected (recovered)');

        emit(processState.copyWith(voip: callSessionState));
      } else if (event is CallEnded) {
        emit(const CanCall());
        logger.info('VoIP call ended (recovered)');
      }
    }

    _preservedCallSessionState.preserve(callSessionState);
    emit(processState.copyWith(voip: callSessionState));
  }

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

    _callThroughTimer?.cancel();
    if (state is! ShowCallThroughSurvey) {
      if (state is Calling) {
        emit(state.finished());
        logger.info('Call-through call ended');
      } else if (state is! NoPermission) {
        emit(const CanCall());
      } else {
        checkCallPermissionIfNotVoip();
      }
    }
  }

  /// For when you're sure the current state is a [CallProcessState].
  CallProcessState get processState => state as CallProcessState;

  void notifySurveyShown() {
    final state = this.state as ShowCallThroughSurvey;

    emit(state.showed());
  }

  @override
  Future<void> close() async {
    _callThroughTimer?.cancel();
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

  Future<void> checkCallPermissionIfNotVoip() async {
    if (Platform.isAndroid && !(await _getHasVoipEnabled())) {
      final status = await _getPermissionStatus(permission: Permission.phone);
      _updateWhetherCanCall(status);
    }
  }

  void _updateWhetherCanCall(PermissionStatus status) {
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
    }
  }
}

/// There are certain values that will be provided throughout the duration of
/// a call session that need to be tracked so they can be reported at the
/// end of a call. This object will hold those values.
class _PreservedCallSessionState {
  var _mos = 0.0;

  double get mos => _mos;

  final usedAudioRoutes = <AudioRoute>{};

  void preserve(CallSessionState state) {
    usedAudioRoutes.add(state.audioState.currentRoute);

    if (state.activeCall != null) {
      final mos = state.activeCall?.mos ?? 0.0;

      if (mos > 0.0) {
        _mos = mos;
      }
    }
  }
}

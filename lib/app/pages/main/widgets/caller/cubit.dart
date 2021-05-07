import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phone_lib/audio/audio_route.dart';
import 'package:flutter_phone_lib/flutter_phone_lib.dart';

import '../../../../../domain/entities/exceptions/call_through.dart';
import '../../../../../domain/entities/exceptions/voip_not_enabled.dart';
import '../../../../../domain/entities/permission.dart';
import '../../../../../domain/entities/permission_status.dart';
import '../../../../../domain/entities/setting.dart';
import '../../../../../domain/entities/survey/survey_trigger.dart';
import '../../../../../domain/usecases/answer_voip_call.dart';
import '../../../../../domain/usecases/call/call.dart';
import '../../../../../domain/usecases/call/voip/end.dart';
import '../../../../../domain/usecases/call/voip/rate_voip_call.dart';
import '../../../../../domain/usecases/call/voip/route_audio.dart';
import '../../../../../domain/usecases/call/voip/toggle_hold.dart';
import '../../../../../domain/usecases/call/voip/toggle_mute.dart';
import '../../../../../domain/usecases/change_setting.dart';
import '../../../../../domain/usecases/get_call_session_state.dart';
import '../../../../../domain/usecases/get_call_through_calls_count.dart';
import '../../../../../domain/usecases/get_has_voip_enabled.dart';
import '../../../../../domain/usecases/get_is_authenticated.dart';
import '../../../../../domain/usecases/get_permission_status.dart';
import '../../../../../domain/usecases/get_setting.dart';
import '../../../../../domain/usecases/get_voip_call_event_stream.dart';
import '../../../../../domain/usecases/increment_call_through_calls_count.dart';
import '../../../../../domain/usecases/metrics/track_call.dart';
import '../../../../../domain/usecases/onboarding/request_permission.dart';
import '../../../../../domain/usecases/open_settings.dart';
import '../../../../../domain/usecases/send_voip_dtmf.dart';
import '../../../../../domain/usecases/start_voip.dart';
import '../../../../util/loggable.dart';
import 'state.dart';

export 'state.dart';

class CallerCubit extends Cubit<CallerState> with Loggable {
  final _isAuthenticated = GetIsAuthenticatedUseCase();

  final _getShowDialerConfirmPopUpSetting =
      GetSettingUseCase<ShowDialerConfirmPopupSetting>();
  final _getShowSurveyDialogSetting =
      GetSettingUseCase<ShowSurveyDialogSetting>();
  final _changeSetting = ChangeSettingUseCase();

  final _call = CallUseCase();
  final _getCallThroughCallsCount = GetCallThroughCallsCountUseCase();
  final _trackCall = TrackCallUseCase();

  final _incrementCallThroughCallsCount =
      IncrementCallThroughCallsCountUseCase();
  final _getPermissionStatus = GetPermissionStatusUseCase();
  final _requestPermission = RequestPermissionUseCase();
  final _openAppSettings = OpenSettingsAppUseCase();

  final _getHasVoipEnabled = GetHasVoipEnabledUseCase();
  final _startVoip = StartVoipUseCase();
  final _getVoipCallEventStream = GetVoipCallEventStreamUseCase();
  final _getCallSessionState = GetCallSessionState();
  final _answerVoipCall = AnswerVoipCallUseCase();
  final _toggleMuteVoipCall = ToggleMuteVoipCallUseCase();
  final _toggleHoldVoipCall = ToggleHoldVoipCallUseCase();
  final _sendVoipDtmf = SendVoipDtmfUseCase();
  final _endVoipCall = EndVoipCallUseCase();
  final _rateVoipCall = RateVoipCallUseCase();
  final _routeAudio = RouteAudioUseCase();

  Timer? _callThroughTimer;

  // For VoIP.
  StreamSubscription? _voipCallEventSubscription;

  CallerCubit() : super(const CanCall()) {
    _isAuthenticated().then((isAuthenticated) {
      if (isAuthenticated) {
        initialize();
      }
    });
  }

  void initialize() {
    checkCallPermissionIfNotVoip();
    _startVoipIfNecessary();
  }

  Future<void> _startVoipIfNecessary() async {
    try {
      await _startVoip();
      _voipCallEventSubscription =
          _getVoipCallEventStream().listen(_onVoipCallEvent);

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
          emit(Calling(origin: CallOrigin.incoming, voip: voip));
        }
      }
    } on VoipNotEnabledException {}
  }

  Future<void> call(
    String destination, {
    required CallOrigin origin,
    bool showingConfirmPage = false,
  }) async {
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
    required int rating,
    required Call call,
  }) async =>
      await _rateVoipCall(rating: rating, call: call);

  Future<void> _callViaCallThrough(
    String destination, {
    required CallOrigin origin,
    bool showingConfirmPage = false,
  }) async {
    final shouldShowConfirmPage = await _getShowDialerConfirmPopUpSetting()
            .then((setting) => setting.value) &&
        !showingConfirmPage;

    // First request to allow to make phone calls,
    // otherwise don't show the call through page at all.
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
      logger.info('Going to call through page');

      emit(
        ShowCallThroughConfirmPage(
          destination: destination,
          origin: origin,
        ),
      );
    } else {
      try {
        _trackCall(via: origin.toTrackString(), voip: false);

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

    logger.info('Starting VoIP call');
    try {
      _trackCall(via: origin.toTrackString(), voip: true);

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
    if (event is IncomingCallReceived) {
      emit(Ringing(voip: event.state!));
      logger.info('Incoming VoIP call, ringing');
    } else if (event is OutgoingCallStarted) {
      final originState = state as CallOriginDetermined;
      emit(InitiatingCall(origin: originState.origin, voip: event.state!));
      logger.info('Initiating VoIP call');
    } else if (event is CallConnected) {
      emit(processState.calling(voip: event.state!));
      logger.info('VoIP call connected');
    } else if (event is CallSessionEvent) {

      // It's possible we're not in a CallProcessState yet, because we missed an
      // event, if that's the case we'll emit the state necessary to get there.
      if (state is! CallProcessState) {
        if (event.state?.activeCall?.direction.isInbound == true) {
          emit(
            Calling(
              origin: CallOrigin.incoming,
              voip: event.state,
            ),
          );
          logger.info('VoIP call connected (recovered)');
        } else {
          throw UnsupportedError(
            'Can\'t recover from missed events of outgoing call',
          );
        }
      }

      emit(processState.copyWith(
        voip: event.state,
      ));
    } else if (event is CallEnded) {
      // It's possible the call ended so fast that we were not in
      // a CallProcessState yet.
      if (state is CallProcessState) {
        emit(processState.finished(voip: event.state));
      } else {
        emit(const CanCall());
      }

      logger.info('VoIP call ended');
    }
  }

  Future<void> toggleMute() async => await _toggleMuteVoipCall();

  Future<void> toggleHoldVoipCall() => _toggleHoldVoipCall();

  Future<void> sendVoipDtmf(String dtmf) => _sendVoipDtmf(dtmf: dtmf);

  Future<void> endVoipCall() => _endVoipCall();

  Future<void> routeAudio(AudioRoute route) async =>
      await _routeAudio(route: route);

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

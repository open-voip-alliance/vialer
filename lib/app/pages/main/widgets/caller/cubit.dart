import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:voip_flutter_integration/voip_flutter_integration.dart';

import '../../../../../domain/entities/exceptions/call_through.dart';
import '../../../../../domain/entities/permission.dart';
import '../../../../../domain/entities/permission_status.dart';
import '../../../../../domain/entities/setting.dart';
import '../../../../../domain/entities/survey/survey_trigger.dart';
import '../../../../../domain/usecases/call.dart';
import '../../../../../domain/usecases/change_setting.dart';
import '../../../../../domain/usecases/end_current_call.dart';
import '../../../../../domain/usecases/get_call_event_stream.dart';
import '../../../../../domain/usecases/get_call_through_calls_count.dart';
import '../../../../../domain/usecases/get_has_voip.dart';
import '../../../../../domain/usecases/get_is_authenticated.dart';
import '../../../../../domain/usecases/get_permission_status.dart';
import '../../../../../domain/usecases/get_settings.dart';
import '../../../../../domain/usecases/increment_call_through_calls_count.dart';
import '../../../../../domain/usecases/metrics/track_call.dart';
import '../../../../../domain/usecases/onboarding/request_permission.dart';
import '../../../../../domain/usecases/open_settings.dart';
import '../../../../../domain/usecases/start_voip.dart';
import '../../../../util/loggable.dart';
import 'state.dart';

export 'state.dart';

class CallerCubit extends Cubit<CallerState> with Loggable {
  final _isAuthenticated = GetIsAuthenticatedUseCase();
  final _getSettings = GetSettingsUseCase();
  final _changeSetting = ChangeSettingUseCase();
  final _call = CallUseCase();
  final _getCallThroughCallsCount = GetCallThroughCallsCountUseCase();
  final _trackCall = TrackCallUseCase();

  final _incrementCallThroughCallsCount =
      IncrementCallThroughCallsCountUseCase();
  final _getPermissionStatus = GetPermissionStatusUseCase();
  final _requestPermission = RequestPermissionUseCase();
  final _openAppSettings = OpenSettingsAppUseCase();

  final _getHasVoip = GetHasVoipUseCase();
  final _startVoip = StartVoipUseCase();
  final _getCallEventStream = GetCallEventStream();
  final _endCurrentCall = EndCurrentCall();

  Timer _callThroughTimer;

  // For VoIP.
  StreamSubscription _callEventSubscription;

  CallerCubit() : super(CanCall()) {
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

  Future<bool> get _useVoip async {
    final settings = await _getSettings();

    // TODO: Using VoIP might be determined by other factors like internet
    // connection quality in the future.
    return await _getHasVoip() && settings.get<UseVoipSetting>().value;
  }

  Future<void> _startVoipIfNecessary() async {
    if (await _useVoip) {
      await _startVoip();
    }
  }

  Future<void> call(
    String destination, {
    @required CallOrigin origin,
    bool showingConfirmPage = false,
  }) async {
    if (await _useVoip) {
      await _callViaVoip(destination, origin: origin);
    } else {
      await _callViaCallThrough(destination, origin: origin);
    }
  }

  Future<void> _callViaCallThrough(
    String destination, {
    @required CallOrigin origin,
    bool showingConfirmPage = false,
  }) async {
    final settings = await _getSettings();

    final shouldShowConfirmPage =
        settings.get<ShowDialerConfirmPopupSetting>().value &&
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
        ShowConfirmPage(
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

              final showSurvey = settings.get<ShowSurveyDialogSetting>().value;

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
    @required CallOrigin origin,
  }) async {
    // TODO: Remove from here
    _requestPermission(permission: Permission.microphone);

    logger.info('Starting VoIP call');
    try {
      _trackCall(via: origin.toTrackString(), voip: true);

      _callEventSubscription = _getCallEventStream().listen(
        (e) => _onCallEvent(e, origin),
      );

      await _call(destination: destination, useVoip: true);

      // When using VoIP, we emit states in _onCallEvent. That's why we don't
      // emit them here like in _callViaCallThrough.

      // TODO: on VoipException
    } on CallThroughException catch (e) {
      emit(processState.failed(e));
    }
  }

  Future<void> _onCallEvent(Event event, CallOrigin origin) async {
    if (event is OutgoingCallStarted) {
      emit(InitiatingCall(origin: origin, call: event.call));
      logger.info('Initiating VoIP call');
    } else if (event is CallConnected) {
      emit(processState.calling(call: event.call));
      logger.info('VoIP call connected');
    } else if (event is CallUpdated) {
      if (processState is InitiatingCall) {
        emit(InitiatingCall(origin: origin, call: event.call));
      } else if (processState is Calling) {
        emit(processState.calling(call: event.call));
      }
    } else if (event is CallEnded) {
      emit(processState.finished());
      await _callEventSubscription.cancel();
      logger.info('VoIP call ended');
    }
  }

  Future<void> endCall() => _endCurrentCall();

  void notifyCanCall() {
    // Necessary for auto cast.
    final state = this.state;

    _callThroughTimer?.cancel();
    if (state is! ShowCallThroughSurvey) {
      if (state is Calling) {
        emit(state.finished());
        logger.info('Call-through call ended');
      } else if (state is! NoPermission) {
        emit(CanCall());
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
    if (Platform.isAndroid && !(await _useVoip)) {
      final status = await _getPermissionStatus(permission: Permission.phone);
      _updateWhetherCanCall(status);
    }
  }

  void _updateWhetherCanCall(PermissionStatus status) {
    if (status == PermissionStatus.granted) {
      emit(CanCall());
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
      case CallOrigin.dialer:
        return 'dialer';
      case CallOrigin.recents:
        return 'recent';
      case CallOrigin.contacts:
        return 'contact';
    }

    throw UnsupportedError(
      'Vialer error: Unknown CallOrigin: $this. '
      'Please add a case to toSegmentString.',
    );
  }
}

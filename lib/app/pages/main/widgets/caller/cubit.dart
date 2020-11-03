import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_segment/flutter_segment.dart';
import 'package:meta/meta.dart';

import '../../../../../domain/entities/call_through_exception.dart';
import '../../../../../domain/entities/setting.dart';
import '../../../../../domain/entities/survey/survey_trigger.dart';
import '../../../../../domain/entities/permission_status.dart';
import '../../../../../domain/entities/permission.dart';

import '../../../../../domain/usecases/call.dart';
import '../../../../../domain/usecases/get_call_through_calls_count.dart';
import '../../../../../domain/usecases/increment_call_through_calls_count.dart';
import '../../../../../domain/usecases/get_settings.dart';
import '../../../../../domain/usecases/change_setting.dart';
import '../../../../../domain/usecases/get_permission_status.dart';
import '../../../../../domain/usecases/onboarding/request_permission.dart';

import '../../../../util/loggable.dart';
import '../../../../util/debug.dart';

import 'state.dart';
export 'state.dart';

class CallerCubit extends Cubit<CallerState> with Loggable {
  final _getSettings = GetSettingsUseCase();
  final _changeSetting = ChangeSettingUseCase();
  final _call = CallUseCase();
  final _getCallThroughCallsCount = GetCallThroughCallsCountUseCase();
  final _incrementCallThroughCallsCount =
      IncrementCallThroughCallsCountUseCase();
  final _getPermissionStatus = GetPermissionStatusUseCase();
  final _requestPermission = RequestPermissionUseCase();

  Timer _callThroughTimer;

  CallerCubit() : super(CanCall()) {
    _checkCallPermission();
  }

  Future<void> call(
    String destination, {
    @required CallOrigin origin,
    bool showingConfirmPage = false,
  }) async {
    doIfNotDebug(() {
      Segment.track(
        eventName: 'call',
        properties: {
          'via': origin.toSegmentString(),
        },
      );
    });

    final settings = await _getSettings();

    final shouldShowConfirmPage =
        settings.get<ShowDialerConfirmPopupSetting>().value &&
            !showingConfirmPage;

    // First check and possibly request to allow to make phone calls,
    // otherwise don't show the call through page at all.
    if (!Platform.isIOS) {
      var status = await _getPermissionStatus(permission: Permission.phone);

      if (status == PermissionStatus.denied) {
        await requestPermission();
        status = await _getPermissionStatus(permission: Permission.phone);
      }

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
      logger.info('Initiating call');
      try {
        emit(InitiatingCall(origin: origin));
        await _call(destination: destination);
        emit(Calling(origin: origin));

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
                  await _changeSetting(setting: ShowSurveyDialogSetting(false));
                }

                emit(ShowCallThroughSurvey(origin: origin));
              }
            }
          },
        );
      } on CallThroughException catch (e) {
        emit(InitiatingCallFailed(e, origin: origin));
      }
    }
  }

  void notifyCanCall() {
    // Necessary for auto cast.
    final state = this.state;

    _callThroughTimer?.cancel();
    if (state is! ShowCallThroughSurvey) {
      if (state is Calling) {
        emit(state.finished());
      } else if (state is! NoPermission) {
        emit(CanCall());
      }
    }
  }

  void notifySurveyShown() {
    final state = this.state as ShowCallThroughSurvey;

    emit(state.showed());
  }

  @override
  Future<void> close() async {
    _callThroughTimer?.cancel();
    await super.close();
  }

  Future<void> requestPermission() async {
    final status = await _requestPermission(permission: Permission.phone);

    _updateWhetherCanCall(status);
  }

  Future<void> _checkCallPermission() async {
    if (!Platform.isIOS) {
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
}

extension on CallOrigin {
  String toSegmentString() {
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

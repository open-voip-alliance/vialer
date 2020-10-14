import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../domain/entities/call_through_exception.dart';
import '../../../../../domain/entities/setting.dart';
import '../../../../../domain/entities/survey/survey_trigger.dart';

import '../../../../../domain/usecases/call.dart';
import '../../../../../domain/usecases/get_call_through_calls_count.dart';
import '../../../../../domain/usecases/increment_call_through_calls_count.dart';
import '../../../../../domain/usecases/get_settings.dart';
import '../../../../../domain/usecases/change_setting.dart';

import '../../../../util/loggable.dart';

import 'state.dart';
export 'state.dart';

class CallerCubit extends Cubit<CallerState> with Loggable {
  final _getSettings = GetSettingsUseCase();
  final _changeSetting = ChangeSettingUseCase();
  final _call = CallUseCase();
  final _getCallThroughCallsCount = GetCallThroughCallsCountUseCase();
  final _incrementCallThroughCallsCount =
      IncrementCallThroughCallsCountUseCase();

  Timer _callThroughTimer;

  CallerCubit() : super(CanCall());

  Future<void> call(
    String destination, {
    bool showingConfirmPage = false,
  }) async {
    final settings = await _getSettings();

    final shouldShowConfirmPage =
        settings.get<ShowDialerConfirmPopupSetting>().value &&
            !showingConfirmPage;

    if (shouldShowConfirmPage) {
      logger.info('Going to call through page');

      emit(ShowConfirmPage(destination: destination));
    } else {
      logger.info('Initiating call');
      try {
        emit(InitiatingCall());
        await _call(destination: destination);
        emit(Calling());

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

                emit(ShowCallThroughSurvey());
              }
            }
          },
        );
      } on CallThroughException catch (e) {
        emit(InitiatingCallFailed(e));
      }
    }
  }

  void notifyCanCall() {
    _callThroughTimer?.cancel();
    emit(CanCall());
  }

  @override
  Future<void> close() async {
    _callThroughTimer?.cancel();
    await super.close();
  }
}

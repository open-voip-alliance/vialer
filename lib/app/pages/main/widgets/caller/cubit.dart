import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../util/loggable.dart';
import '../../../../../domain/entities/call_through_exception.dart';
import '../../../../../domain/entities/setting.dart';
import '../../../../../domain/usecases/call.dart';

import '../../../../../domain/usecases/get_call_through_calls_count.dart';
import '../../../../../domain/usecases/increment_call_through_calls_count.dart';

import '../../../../../domain/usecases/get_settings.dart';

import 'state.dart';
export 'state.dart';

class CallerCubit extends Cubit<CallerState> with Loggable {
  final _getSettings = GetSettingsUseCase();
  final _call = CallUseCase();
  final _getCallThroughCallsCount = GetCallThroughCallsCountUseCase();
  final _incrementCallThroughCallsCount =
      IncrementCallThroughCallsCountUseCase();

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
        _incrementCallThroughCallsCount();

        final count = _getCallThroughCallsCount();
        if (count >= 3) {
          emit(ShowCallThroughSurvey(popPrevious: showingConfirmPage));
        }
      } on CallThroughException catch (e) {
        emit(InitiatingCallFailed(e));
      }
    }
  }

  void notifyCanCall() => emit(CanCall());
}

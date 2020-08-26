import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../util/loggable.dart';
import '../../../../../domain/entities/call_through_exception.dart';
import '../../../../../domain/entities/setting.dart';
import '../../../../../domain/usecases/call.dart';

import '../../../../../domain/usecases/get_settings.dart';

import 'state.dart';
export 'state.dart';

class CallerCubit extends Cubit<CallerState> with Loggable {
  final _getSettings = GetSettingsUseCase();
  final _call = CallUseCase();

  CallerCubit() : super(CanCall());

  Future<void> call(String destination) async {
    final settings = await _getSettings();

    final shouldShowConfirmPage =
        settings.get<ShowDialerConfirmPopupSetting>()?.value ?? true;

    if (shouldShowConfirmPage) {
      logger.info('Going to call through page');

      emit(ShowConfirmPage(destination: destination));
    } else {
      logger.info('Initiating call');
      try {
        emit(InitiatingCall());
        _call(destination: destination);
      } on CallThroughException catch (e) {
        emit(InitiatingCallFailed(e));
      }
    }
  }

  void notifyCanCall() => emit(CanCall());
}

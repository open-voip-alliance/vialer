import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../domain/calling/call_through/get_call_through_region_number.dart';
import '../../../../../../domain/user/get_logged_in_user.dart';
import '../../../../../../domain/user/settings/app_setting.dart';
import '../../../../../../domain/user/settings/call_setting.dart';
import '../../../../../../domain/user/settings/change_setting.dart';
import '../../../../../util/loggable.dart';
import '../../../widgets/caller.dart';
import 'state.dart';

export 'state.dart';

class ConfirmCubit extends Cubit<ConfirmState> with Loggable {
  final _changeSetting = ChangeSettingUseCase();
  final _getCallThroughRegionNumber = GetCallThroughRegionNumberUseCase();

  final CallerCubit _caller;
  final String _destination;

  ConfirmCubit(this._caller, this._destination)
      : super(
          ConfirmState(
            showConfirmPage: true,
            outgoingNumber: GetLoggedInUserUseCase()()
                .settings
                .get(CallSetting.outgoingNumber),
          ),
        ) {
    _emitInitialState();
  }

  Future<void> _emitInitialState() async {
    emit(
      state.copyWith(
        regionNumber: await _getCallThroughRegionNumber(
          destination: _destination,
        ),
      ),
    );
  }

  // ignore: avoid_positional_boolean_parameters
  Future<void> updateShowPopupSetting(bool showConfirmPage) async {
    await _changeSetting(AppSetting.showDialerConfirmPopup, showConfirmPage);

    emit(state.copyWith(showConfirmPage: showConfirmPage));
  }

  Future<void> call({required CallOrigin origin}) => _caller.call(
        _destination,
        origin: origin,
        showingConfirmPage: true,
      );

  void cancelCallThroughCall() {
    logger.info('Cancel call-through call');
    _caller.notifyCanCall();
  }
}

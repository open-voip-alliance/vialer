import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vialer/data/models/user/user.dart';

import '../../../../../../data/models/user/settings/app_setting.dart';
import '../../../../../../data/models/user/settings/call_setting.dart';
import '../../../../../../domain/usecases/calling/call_through/get_call_through_region_number.dart';
import '../../../../../../domain/usecases/user/get_logged_in_user.dart';
import '../../../../../../domain/usecases/user/settings/change_setting.dart';
import '../../../../util/loggable.dart';
import '../../../widgets/caller.dart';
import 'state.dart';

export 'state.dart';

class ConfirmCubit extends Cubit<ConfirmState> with Loggable {
  ConfirmCubit(this._caller, this._destination)
      : super(
          ConfirmState(
            showConfirmPage: true,
            outgoingNumber: GetLoggedInUserUseCase()()
                .settings
                .get(CallSetting.outgoingNumber),
          ),
        ) {
    unawaited(_emitInitialState());
  }

  final _changeSetting = ChangeSettingUseCase();
  final _getCallThroughRegionNumber = GetCallThroughRegionNumberUseCase();

  final CallerCubit _caller;
  final String _destination;

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

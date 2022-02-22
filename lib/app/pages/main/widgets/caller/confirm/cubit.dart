import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../domain/entities/setting.dart';
import '../../../../../../domain/usecases/change_setting.dart';
import '../../../../../../domain/usecases/get_call_through_region_number.dart';
import '../../../../../../domain/usecases/get_outgoing_cli.dart';
import '../../../../../util/loggable.dart';
import '../../../widgets/caller.dart';
import 'state.dart';

export 'state.dart';

class ConfirmCubit extends Cubit<ConfirmState> with Loggable {
  final _changeSetting = ChangeSettingUseCase();
  final _getOutgoingCli = GetOutgoingCliUseCase();
  final _getCallThroughRegionNumber = GetCallThroughRegionNumberUseCase();

  final CallerCubit _caller;
  final String _destination;

  ConfirmCubit(this._caller, this._destination)
      : super(const ConfirmState(showConfirmPage: true)) {
    _emitInitialState();
  }

  Future<void> _emitInitialState() async {
    emit(
      state.copyWith(
        outgoingCli: await _getOutgoingCli(),
        regionNumber: await _getCallThroughRegionNumber(
          destination: _destination,
        ),
      ),
    );
  }

  // ignore: avoid_positional_boolean_parameters
  Future<void> updateShowPopupSetting(bool showConfirmPage) async {
    await _changeSetting(
      setting: ShowDialerConfirmPopupSetting(showConfirmPage),
    );

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

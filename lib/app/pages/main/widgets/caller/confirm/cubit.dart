import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

import '../../../../../../domain/entities/setting.dart';

import '../../../../../../domain/usecases/change_setting.dart';
import '../../../../../../domain/usecases/get_outgoing_cli.dart';

import '../../../widgets/caller.dart';

import '../../../../../util/loggable.dart';

import 'state.dart';
export 'state.dart';

class ConfirmCubit extends Cubit<ConfirmState> with Loggable {
  final _changeSetting = ChangeSettingUseCase();
  final _getOutgoingCli = GetOutgoingCliUseCase();

  final CallerCubit _caller;
  final String _destination;

  ConfirmCubit(this._caller, this._destination)
      : super(ConfirmState(showConfirmPage: true)) {
    emit(state.copyWith(outgoingCli: _getOutgoingCli()));
  }

  // ignore: avoid_positional_boolean_parameters
  Future<void> updateShowPopupSetting(bool showConfirmPage) async {
    await _changeSetting(
      setting: ShowDialerConfirmPopupSetting(showConfirmPage),
    );

    emit(ConfirmState(showConfirmPage: showConfirmPage));
  }

  Future<void> call({@required CallOrigin origin}) => _caller.call(
        _destination,
        origin: origin,
        showingConfirmPage: true,
      );
}

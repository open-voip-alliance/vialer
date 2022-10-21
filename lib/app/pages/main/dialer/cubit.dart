import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/calling/get_latest_dialed_number.dart';
import '../widgets/caller/cubit.dart';
import 'state.dart';

export 'state.dart';

class DialerCubit extends Cubit<DialerState> {
  final _getLatestDialedNumber = GetLatestDialedNumberUseCase();

  final CallerCubit _caller;

  DialerCubit(this._caller)
      : super(
          DialerState(
            lastCalledDestination: GetLatestDialedNumberUseCase()(),
          ),
        );

  Future<void> call(String destination) async {
    if (destination.isEmpty) {
      emit(
        DialerState(lastCalledDestination: _getLatestDialedNumber()),
      );
      return;
    }

    await _caller.call(destination, origin: CallOrigin.dialer);
  }

  void clearLastCalledDestination() {
    emit(DialerState());
  }
}

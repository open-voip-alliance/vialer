import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../domain/user_availability/colleagues/receive_colleague_availability.dart';
import '../../../../../domain/user_availability/colleagues/stop_receiving_colleague_availability.dart';
import 'state.dart';
export 'state.dart';

class ColleagueCubit extends Cubit<ColleagueState> {
  late final _receiveColleagueAvailability = ReceiveColleagueAvailability();
  late final _stopReceivingColleagueAvailability = StopReceivingColleagueAvailability();

  ColleagueCubit() : super(const ColleagueState.loading());

  void connectToWebSocket() {
    _receiveColleagueAvailability().listen((colleagues) {
      emit(ColleagueState.loaded(colleagues));
    });
  }

  void disconnectFromWebSocket() {
    _stopReceivingColleagueAvailability();
  }
}

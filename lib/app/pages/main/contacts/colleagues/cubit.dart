import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../domain/user_availability/colleagues/receive_colleague_availability.dart';
import 'state.dart';
export 'state.dart';

class ColleagueCubit extends Cubit<ColleagueState> {
  late final _receiveColleagueAvailability = ReceiveColleagueAvailability();

  ColleagueCubit() : super(const ColleagueState.loading()) {
    _receiveColleagueAvailability().listen((colleagues) {
      emit(ColleagueState.loaded(colleagues));
    });
  }
}

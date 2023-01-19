import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../dependency_locator.dart';
import '../../../../../domain/authentication/user_was_logged_out.dart';
import '../../../../../domain/event/event_bus.dart';
import '../../../../../domain/user_availability/colleagues/receive_colleague_availability.dart';
import '../../../../../domain/user_availability/colleagues/stop_receiving_colleague_availability.dart';
import 'state.dart';
export 'state.dart';

class ColleagueCubit extends Cubit<ColleagueState> {
  late final _receiveColleagueAvailability = ReceiveColleagueAvailability();
  late final _stopReceivingColleagueAvailability =
      StopReceivingColleagueAvailability();
  final _eventBus = dependencyLocator<EventBusObserver>();

  ColleagueCubit() : super(const ColleagueState.loading()) {
    _eventBus.on<UserWasLoggedOutEvent>((event) {
      _stopReceivingColleagueAvailability(purgeCache: true);
    });
  }

  void connectToWebSocket() {
    _receiveColleagueAvailability().listen((colleagues) {
      // Emitting loading initially to ensure listeners receive the new state.
      emit(const ColleagueState.loading());
      emit(ColleagueState.loaded(colleagues));
    });
  }

  void disconnectFromWebSocket() {
    _stopReceivingColleagueAvailability();
  }
}

import 'dart:async';

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

  StreamSubscription? _subscription;

  ColleagueCubit() : super(const ColleagueState.loading()) {
    _eventBus.on<UserWasLoggedOutEvent>((event) {
      _stopReceivingColleagueAvailability(purgeCache: true);
    });
  }

  Future<void> connectToWebSocket({bool fullRefresh = false}) async {
    if (_subscription != null) return;

    final stream = await _receiveColleagueAvailability(
      forceFullAvailabilityRefresh: fullRefresh,
    );

    _subscription = stream.listen(
      (colleagues) {
        // Emitting loading initially to ensure listeners receive the new state.
        emit(const ColleagueState.loading());
        emit(ColleagueState.loaded(colleagues));
      },
      onDone: () {
        emit(const ColleagueState.unreachable());
      },
      onError: (_) {
        emit(const ColleagueState.unreachable());
      },
    );
  }

  Future<void> disconnectFromWebSocket() async {
    _subscription?.cancel();
    _subscription = null;
    _stopReceivingColleagueAvailability();
  }

  /// Refresh the WebSocket, disconnecting and reconnecting to load all
  /// new data.
  ///
  /// This should only be called on a specific user-action as it has a large
  /// amount of overhead.
  Future<void> refresh() async {
    await disconnectFromWebSocket();
    connectToWebSocket(fullRefresh: true);
  }
}

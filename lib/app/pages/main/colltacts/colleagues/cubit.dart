import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../../dependency_locator.dart';
import '../../../../../domain/authentication/user_was_logged_out.dart';
import '../../../../../domain/event/event_bus.dart';
import '../../../../../domain/user_availability/colleagues/receive_colleague_availability.dart';
import '../../../../../domain/user_availability/colleagues/should_show_colleagues.dart';
import '../../../../../domain/user_availability/colleagues/stop_receiving_colleague_availability.dart';
import 'state.dart';

export 'state.dart';

class ColleagueCubit extends Cubit<ColleagueState> {
  late final _shouldShowColleagues = ShouldShowColleagues();
  late final _receiveColleagueAvailability = ReceiveColleagueAvailability();
  late final _stopReceivingColleagueAvailability =
      StopReceivingColleagueAvailability();
  final _eventBus = dependencyLocator<EventBusObserver>();

  StreamSubscription? _subscription;

  ColleagueCubit() : super(const ColleagueState.loading()) {
    _eventBus.on<UserWasLoggedOutEvent>((event) {
      disconnectFromWebSocket(purgeCache: true);
    });
  }

  Future<void> connectToWebSocket({bool fullRefresh = false}) async {
    if (!_shouldShowColleagues() || _subscription != null) return;

    emit(const ColleagueState.loading());

    final stream = await _receiveColleagueAvailability(
      forceFullAvailabilityRefresh: fullRefresh,
    );

    _subscription =
        stream.debounceTime(const Duration(milliseconds: 250)).listen(
      (colleagues) {
        // Emitting loading initially to ensure listeners receive the new state.
        // emit(const ColleagueState.loading());
        emit(ColleagueState.loaded(colleagues));
      },
      onDone: () {
        _subscription?.cancel();
        _subscription = null;
        emit(const ColleagueState.unreachable());
      },
    );
  }

  Future<void> disconnectFromWebSocket({bool purgeCache = false}) async {
    _subscription?.cancel();
    _subscription = null;
    _stopReceivingColleagueAvailability(purgeCache: purgeCache);
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

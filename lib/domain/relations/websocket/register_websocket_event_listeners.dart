import 'package:vialer/domain/relations/websocket/events/user_availability_changed.dart';
import 'package:vialer/domain/use_case.dart';
import 'package:vialer/domain/user/get_logged_in_user.dart';

import '../../../dependency_locator.dart';
import '../../event/event_bus.dart';
import '../../user/events/logged_in_user_availability_changed.dart';
import '../../user/user.dart';
import '../colleagues/colleague.dart';
import '../user_availability_status.dart';

/// Registers any global websocket event listeners, this is most likely used
/// when translating websocket events to app events.
///
/// Not all listeners need to be registered here, for example it is perfectly
/// valid to listen within a cubit - and you'd want to have full control over
/// registering the listener there.
class RegisterWebSocketEventListeners extends UseCase {

  late final _eventBus = dependencyLocator<EventBusObserver>();
  User get user => GetLoggedInUserUseCase()();

  Future<void> call() async {
    _eventBus.on<UserAvailabilityChangedPayload>((event) {
      // We are going to hijack this WebSocket and emit an event when we
      // know our user has changed on the server.
      if (event.userUuid == user.uuid) {
        dependencyLocator<EventBus>().broadcast(
          LoggedInUserAvailabilityChanged(
            availability: event,
            userAvailabilityStatus: event.toUserAvailabilityStatus(),
          ),
        );
      }
    });
  }
}

extension on UserAvailabilityChangedPayload {
  UserAvailabilityStatus toUserAvailabilityStatus() {
    if (destinationType == ColleagueDestinationType.voipAccount &&
        availability == ColleagueAvailabilityStatus.offline) {
      return UserAvailabilityStatus.onlineWithRingingDeviceOffline;
    }

    return switch (availability) {
      ColleagueAvailabilityStatus.available => UserAvailabilityStatus.online,
      ColleagueAvailabilityStatus.busy => UserAvailabilityStatus.online,
      ColleagueAvailabilityStatus.unknown => UserAvailabilityStatus.online,
      ColleagueAvailabilityStatus.offline => UserAvailabilityStatus.offline,
      ColleagueAvailabilityStatus.doNotDisturb =>
      UserAvailabilityStatus.doNotDisturb,
    };
  }
}
import 'package:vialer/domain/relations/websocket/listeners/colleague_update_handler.dart';
import 'package:vialer/domain/relations/websocket/listeners/listener.dart';
import 'package:vialer/domain/relations/websocket/payloads/user_availability_changed.dart';

import '../../../user/events/logged_in_user_availability_changed.dart';
import '../../colleagues/colleague.dart';
import '../../user_availability_status.dart';
import '../payloads/payload.dart';

class BroadcastLoggedInUserAvailability
    extends Listener<UserAvailabilityChangedPayload> {
  @override
  bool shouldHandle(Payload payload) {
    if (payload is! UserAvailabilityChangedPayload) return false;

    return payload.isAboutLoggedInUser;
  }

  @override
  Future<void> handle(UserAvailabilityChangedPayload payload) async {
    broadcast(
      LoggedInUserAvailabilityChanged(
        availability: payload,
        userAvailabilityStatus: payload.toUserAvailabilityStatus(),
      ),
    );
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

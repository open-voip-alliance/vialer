import 'package:vialer/domain/relations/websocket/listeners/listener.dart';
import 'package:vialer/domain/relations/websocket/payloads/user_availability_changed.dart';
import 'package:vialer/domain/user/get_stored_user.dart';

import '../../../user/events/logged_in_user_availability_changed.dart';
import '../../../user/user.dart';
import '../../colleagues/colleague.dart';
import '../../user_availability_status.dart';
import '../payloads/payload.dart';

class BroadcastLoggedInUserAvailability
    extends Listener<UserAvailabilityChangedPayload> {
  User? get _user => GetStoredUserUseCase()();

  @override
  bool shouldHandle(Payload payload) {
    if (payload is! UserAvailabilityChangedPayload) return false;

    final user = _user;

    if (user == null) return false;

    return user.uuid == payload.userUuid;
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

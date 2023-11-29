import 'package:vialer/domain/relations/websocket/listeners/colleague_update_handler.dart';
import 'package:vialer/domain/relations/websocket/listeners/listener.dart';
import 'package:vialer/domain/relations/websocket/payloads/user_availability_changed.dart';

import '../../../onboarding/is_onboarded.dart';
import '../../../user/events/logged_in_user_availability_changed.dart';
import '../../../user/refresh/refresh_user.dart';
import '../../../user/refresh/user_refresh_task.dart';
import '../../colleagues/colleague.dart';
import '../../user_availability_status.dart';
import '../payloads/payload.dart';

class LoggedInUserAvailabilityChangedHandler
    extends Listener<UserAvailabilityChangedPayload> {
  /// The previous payload that we received so we only broadcast this event
  /// when their availability has actually changed.
  UserAvailabilityChangedPayload? previous;

  late final _refreshUser = RefreshUser();
  late final _isOnboarded = IsOnboarded();

  @override
  bool shouldHandle(Payload payload) {
    if (payload is! UserAvailabilityChangedPayload) return false;

    return payload.isAboutLoggedInUser;
  }

  @override
  Future<void> handle(UserAvailabilityChangedPayload payload) async {
    if (previous == payload) return;

    previous = payload;

    await _refreshSelectedDestination();

    broadcast(
      LoggedInUserAvailabilityChanged(
        availability: payload,
        userAvailabilityStatus: payload.toUserAvailabilityStatus(),
        isRingingDeviceOffline: payload.isRingingDeviceOffline,
      ),
    );
  }

  Future<void> _refreshSelectedDestination() async {
    if (!_isOnboarded()) return;

    await _refreshUser(
      tasksToPerform: [
        UserRefreshTask.userDetails,
        UserRefreshTask.appAccount,
      ],
    );
  }
}

extension on UserAvailabilityChangedPayload {
  bool get isRingingDeviceOffline =>
      userStatus != ColleagueAvailabilityStatus.offline &&
      destinationType == ColleagueDestinationType.voipAccount &&
      availability == ColleagueAvailabilityStatus.offline;

  UserAvailabilityStatus toUserAvailabilityStatus() => switch (userStatus) {
        ColleagueAvailabilityStatus.offline => UserAvailabilityStatus.offline,
        ColleagueAvailabilityStatus.doNotDisturb =>
          UserAvailabilityStatus.doNotDisturb,
        _ => UserAvailabilityStatus.online,
      };
}

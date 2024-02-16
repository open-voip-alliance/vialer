import 'package:vialer/data/models/calling/voip/destination.dart';
import 'package:vialer/data/models/relations/utils.dart';
import 'package:vialer/data/models/relations/websocket/listeners/colleague_update_handler.dart';
import 'package:vialer/data/repositories/calling/voip/destination_repository.dart';
import 'package:vialer/dependency_locator.dart';

import '../../../../../domain/usecases/onboarding/is_onboarded.dart';
import '../../../../../domain/usecases/user/refresh/refresh_user.dart';
import '../../../../../domain/usecases/user/settings/force_update_setting.dart';
import '../../../user/events/logged_in_user_availability_changed.dart';
import '../../../user/refresh/user_refresh_task.dart';
import '../../../user/settings/call_setting.dart';
import '../../colleagues/colleague.dart';
import '../../user_availability_status.dart';
import '../payloads/payload.dart';
import '../payloads/user_availability_changed.dart';
import 'listener.dart';

class LoggedInUserAvailabilityChangedHandler
    extends Listener<UserAvailabilityChangedPayload> {
  late final _refreshUser = RefreshUser();
  late final _isOnboarded = IsOnboarded();
  late final _destinations = dependencyLocator<DestinationRepository>();

  @override
  bool shouldHandle(Payload payload) {
    if (payload is! UserAvailabilityChangedPayload) return false;

    return payload.isAboutLoggedInUser;
  }

  @override
  Future<void> handle(UserAvailabilityChangedPayload payload) async {
    _updateLocalSelectedDestinationSetting(payload.selectedDestination);

    broadcast(
      LoggedInUserAvailabilityChanged(
        availability: payload,
        userAvailabilityStatus: payload.toUserAvailabilityStatus(),
        isRingingDeviceOffline: payload.isRingingDeviceOffline,
      ),
    );
  }

  /// Updates our local setting that stores the selected destination, we are
  /// trying to avoid additional API requests here as much as possible - so we
  /// will only perform the API request if we can't find the destination
  /// provided by the websocket in our locally stored list.
  Future<void> _updateLocalSelectedDestinationSetting(
    SelectedDestination? selectedDestination,
  ) async {
    if (selectedDestination == null) {
      return _updateSetting(Destination.notAvailable());
    }

    final found = _destinations.availableDestinations
        .findById(selectedDestination.destinationId);

    // We don't have this destination stored so we will have to make the API
    // request.
    if (found == null) {
      return _refreshSelectedDestinationViaApi();
    }

    return _updateSetting(found);
  }

  Future<void> _updateSetting(Destination destination) => ForceUpdateSetting()(
        CallSetting.destination,
        destination.identifier,
      );

  Future<void> _refreshSelectedDestinationViaApi() async {
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

  UserAvailabilityStatus toUserAvailabilityStatus() =>
      userStatus.toUserAvailabilityStatus();
}

extension on List<Destination> {
  Destination? findById(int id) => where(
        (destination) => destination.identifier == id,
      ).firstOrNull;
}

import 'dart:async';

import 'package:vialer/domain/calling/voip/destination.dart';
import 'package:vialer/domain/calling/voip/destination_repository.dart';
import 'package:vialer/domain/user/get_logged_in_user.dart';

import '../../../../app/util/loggable.dart';
import '../../../../dependency_locator.dart';
import '../../../relations/availability/availability_status_repository.dart';
import '../../../relations/user_availability_status.dart';
import '../../../user/user.dart';
import '../call_setting.dart';
import 'setting_change_listener.dart';

class UpdateAvailabilityStatus
    extends SettingChangeListener<UserAvailabilityStatus> with Loggable {
  UserAvailabilityStatusRepository get _repository =>
      dependencyLocator<UserAvailabilityStatusRepository>();

  @override
  final key = CallSetting.availabilityStatus;

  @override
  FutureOr<SettingChangeListenResult> applySettingsSideEffects(
    User user,
    UserAvailabilityStatus value,
  ) async {
    final success = await _updateLegacyDestinationForStatus(value);

    if (success) {
      await _repository.changeStatus(GetLoggedInUserUseCase()(), value);
    }

    return successResult;
  }

  // Temporary functionality to set the destination when the user status
  // changes. This should be removed when the back-end is properly handling
  // offline status.
  Future<bool> _updateLegacyDestinationForStatus(
    UserAvailabilityStatus status,
  ) async {
    final user = GetLoggedInUserUseCase()();
    final repo = dependencyLocator<DestinationRepository>();
    final dest = [
      UserAvailabilityStatus.online,
      UserAvailabilityStatus.doNotDisturb,
    ].contains(status)
        ? repo.availableDestinations.findHighestPriorityDestinationFor(
            user: user,
          )
        : Destination.notAvailable();

    if (dest == null) {
      return true;
    }

    return repo.setDestination(destination: dest);
  }
}

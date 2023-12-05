import 'package:dartx/dartx.dart';
import 'package:vialer/dependency_locator.dart';
import 'package:vialer/domain/calling/voip/destination_repository.dart';
import 'package:vialer/domain/user/refresh/user_refresh_task_performer.dart';
import 'package:vialer/domain/user/user.dart';

import '../../../calling/voip/destination.dart';
import '../../details/user_details.dart';
import '../../settings/call_setting.dart';

class RefreshUserDetails extends UserRefreshTaskPerformer {
  UserDetailsRepository get _userDetails =>
      dependencyLocator<UserDetailsRepository>();

  DestinationRepository get _destinations =>
      dependencyLocator<DestinationRepository>();

  const RefreshUserDetails();

  @override
  Future<UserMutator> performUserRefreshTask(User user) async {
    final userDetails = await _userDetails.getUserDetails();

    _storeSelectedDestinationId(userDetails);

    return (User user) {
      _updateDestinationList(userDetails);
      _updateUseMobileNumberAsFallback(userDetails);
      _updateSelectedDestination(userDetails);

      return user.copyWith(
        webphoneAccountId: () => userDetails.webphone?.voipAccount?.id,
      );
    };
  }

  void _storeSelectedDestinationId(UserDetails userDetails) {
    final selectedDestinationId = userDetails.selectedDestination?.id;

    if (selectedDestinationId != null) {
      _destinations.selectedUserDestinationId = selectedDestinationId.toInt();
    }
  }

  void _updateSelectedDestination(UserDetails userDetails) => updateSetting(
        CallSetting.destination,
        (userDetails.selectedDestination?.asDestination() ??
                Destination.notAvailable())
            .identifier,
      );

  void _updateDestinationList(UserDetails userDetails) =>
      _destinations.updateDestinations(userDetails.availableDestinations);

  void _updateUseMobileNumberAsFallback(UserDetails userDetails) =>
      updateSetting(
        CallSetting.useMobileNumberAsFallback,
        userDetails.app?.useMobileNumberAsFallback ?? false,
      );
}

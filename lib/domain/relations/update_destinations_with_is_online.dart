import 'package:vialer/dependency_locator.dart';
import 'package:vialer/domain/event/event_bus.dart';
import 'package:vialer/domain/feature/has_feature.dart';
import 'package:vialer/domain/relations/websocket/payloads/user_devices_changed.dart';
import 'package:vialer/domain/user/events/user_devices_changed.dart';
import 'package:vialer/domain/user/get_logged_in_user.dart';
import 'package:vialer/domain/user/settings/call_setting.dart';

import '../calling/voip/destination_repository.dart';
import '../feature/feature.dart';
import '../use_case.dart';
import '../user/settings/force_update_setting.dart';
import '../user/user.dart';

class UpdateDestinationsWithIsOnline extends UseCase {
  final _destinationRepository = dependencyLocator<DestinationRepository>();
  final _eventBus = dependencyLocator<EventBus>();
  User get _user => GetLoggedInUserUseCase()();

  Future<void> call(UserDevicesChangedPayload payload) async {
    if (doesNotHaveFeature(Feature.offlineUserDevices)) return;

    for (final device in payload.devices) {
      await _destinationRepository.updateIsOnline(
        device.accountId,
        device.isOnline,
      );
    }

    final currentDestination = _user.settings.getOrNull(CallSetting.destination);

    if (currentDestination != null) {
      await ForceUpdateSetting()(CallSetting.destination, currentDestination.map(unknown: unknown, notAvailable: notAvailable, phoneNumber: phoneNumber, phoneAccount: phoneAccount,),);
    }

    return _eventBus.broadcast(
      UserDevicesChanged(_destinationRepository.availableDestinations),
    );
  }
}

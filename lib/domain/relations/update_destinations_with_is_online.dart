import 'package:vialer/dependency_locator.dart';
import 'package:vialer/domain/event/event_bus.dart';
import 'package:vialer/domain/feature/has_feature.dart';
import 'package:vialer/domain/relations/websocket/payloads/user_devices_changed.dart';
import 'package:vialer/domain/user/events/user_devices_changed.dart';

import '../calling/voip/destination_repository.dart';
import '../feature/feature.dart';
import '../use_case.dart';

class UpdateDestinationsWithIsOnline extends UseCase {
  final _destinationRepository = dependencyLocator<DestinationRepository>();
  final _eventBus = dependencyLocator<EventBus>();

  Future<void> call(UserDevicesChangedPayload payload) async {
    if (doesNotHaveFeature(Feature.offlineUserDevices)) return;

    for (final device in payload.devices) {
      await _destinationRepository.updateIsOnline(
        device.accountId,
        device.isOnline,
      );
    }

    return _eventBus.broadcast(
      UserDevicesChanged(_destinationRepository.availableDestinations),
    );
  }
}

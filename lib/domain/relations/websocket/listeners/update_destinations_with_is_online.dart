import 'package:vialer/domain/relations/websocket/listeners/listener.dart';
import 'package:vialer/domain/user/events/user_devices_changed.dart';

import '../../../../dependency_locator.dart';
import '../../../calling/voip/destination_repository.dart';
import '../payloads/user_devices_changed.dart';

class UpdateDestinationWithIsOnline
    extends Listener<UserDevicesChangedPayload> {
  late final _destinationRepository =
      dependencyLocator<DestinationRepository>();

  @override
  Future<void> handle(UserDevicesChangedPayload payload) async {
    for (final device in payload.devices) {
      await _destinationRepository.updateIsOnline(
        device.accountId,
        device.isOnline,
      );
    }

    return broadcast(
      UserDevicesChanged(_destinationRepository.availableDestinations),
    );
  }
}

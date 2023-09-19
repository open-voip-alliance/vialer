import 'package:vialer/dependency_locator.dart';
import 'package:vialer/domain/feature/has_feature.dart';
import 'package:vialer/domain/relations/websocket/payloads/user_devices_changed.dart';

import '../calling/voip/destination_repository.dart';
import '../feature/feature.dart';
import '../use_case.dart';

class UpdateDestinationsWithIsOnline extends UseCase {
  final _destinationRepository = dependencyLocator<DestinationRepository>();

  Future<void> call(UserDevicesChangedPayload payload) async {
    if (!hasFeature(Feature.offlineUserDevices)) return;

    return payload.devices.forEach((device) {
      _destinationRepository.updateIsOnline(device.accountId, device.isOnline);
    });
  }
}

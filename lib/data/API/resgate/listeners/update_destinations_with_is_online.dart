import '../../../../dependency_locator.dart';
import '../../../models/user/events/user_devices_changed.dart';
import '../../../repositories/calling/voip/destination_repository.dart';
import '../payloads/device.dart';
import '../rid_generator.dart';
import 'listener.dart';

class UpdateDestinationWithIsOnline extends ResgateListener<DevicePayload>
    with RidGenerator {
  late final _destinationRepository =
      dependencyLocator<DestinationRepository>();

  @override
  Future<void> handle(DevicePayload device) async {
    await _destinationRepository.updateIsOnline(
      device.accountId,
      device.isOnline,
    );

    return broadcast(
      UserDevicesChanged(_destinationRepository.availableDestinations),
    );
  }

  @override
  String get resourceToSubscribeTo => createRid(
        (user, client) => 'availability.client.$client.user.$user.device',
      );

  @override
  RegExp get resourceToHandle => RegExp(resourceToSubscribeTo + r'.[0-9]+$');
}

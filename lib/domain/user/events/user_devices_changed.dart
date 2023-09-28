import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vialer/domain/event/event_bus.dart';

import '../../calling/voip/destination.dart';

part 'user_devices_changed.freezed.dart';

@freezed
class UserDevicesChanged with _$UserDevicesChanged implements EventBusEvent {
  const factory UserDevicesChanged(List<Destination> destinations) =
      _UserDevicesChanged;
}

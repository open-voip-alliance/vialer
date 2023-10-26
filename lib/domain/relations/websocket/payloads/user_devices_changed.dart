import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vialer/domain/relations/websocket/payloads/payload.dart';

part 'user_devices_changed.freezed.dart';
part 'user_devices_changed.g.dart';

@freezed
class UserDevicesChangedPayload
    with _$UserDevicesChangedPayload
    implements Payload {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory UserDevicesChangedPayload({
    required String userUuid,
    required List<Device> devices,
  }) = _UserDevicesChangedPayload;

  factory UserDevicesChangedPayload.fromJson(Map<String, dynamic> json) =>
      _$UserDevicesChangedPayloadFromJson(json);
}

@freezed
class Device with _$Device {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Device({
    required int accountId,
    required bool isSipRegistered,
    @JsonKey(name: 'has_appregistration') required bool hasAppRegistration,
    required bool isOnline,
  }) = _Device;

  factory Device.fromJson(Map<String, dynamic> json) => _$DeviceFromJson(json);
}

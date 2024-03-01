import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vialer/data/API/resgate/payloads/payload.dart';

part 'device.freezed.dart';
part 'device.g.dart';

@freezed
class DevicePayload with _$DevicePayload implements ResgatePayload {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory DevicePayload({
    required int accountId,
    required bool isSipRegistered,
    @JsonKey(name: 'has_appregistration') required bool hasAppRegistration,
    required bool isOnline,
  }) = _DevicePayload;

  factory DevicePayload.fromJson(Map<String, dynamic> json) =>
      _$DevicePayloadFromJson(json);
}

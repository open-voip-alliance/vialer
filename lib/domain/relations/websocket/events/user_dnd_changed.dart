import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../event/event_bus.dart';

part 'user_dnd_changed.freezed.dart';
part 'user_dnd_changed.g.dart';

@freezed
class UserDndChangedPayload
    with _$UserDndChangedPayload
    implements EventBusEvent {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory UserDndChangedPayload({
    required String userUuid,
    required bool dnd,
  }) = _UserDndChangedPayload;

  factory UserDndChangedPayload.fromJson(Map<String, dynamic> json) =>
      _$UserDndChangedPayloadFromJson(json);
}

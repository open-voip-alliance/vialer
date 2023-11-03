import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vialer/domain/relations/websocket/payloads/payload.dart';

import '../../colleagues/colleague.dart';

part 'user_availability_changed.freezed.dart';
part 'user_availability_changed.g.dart';

@freezed
class UserAvailabilityChangedPayload
    with _$UserAvailabilityChangedPayload
    implements Payload {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory UserAvailabilityChangedPayload({
    required String userUuid,
    required bool hasLinkedDestinations,
    required int internalNumber,
    @JsonKey(fromJson: _colleagueDestinationTypeFromJson)
    required ColleagueDestinationType destinationType,
    @JsonKey(fromJson: _availabilityFromJson)
    required ColleagueAvailabilityStatus availability,
    @JsonKey(fromJson: _colleagueContextFromJson)
    required List<ColleagueContext> context,
  }) = _UserAvailabilityChangedPayload;

  factory UserAvailabilityChangedPayload.fromJson(Map<String, dynamic> json) =>
      _$UserAvailabilityChangedPayloadFromJson(json);
}

ColleagueAvailabilityStatus _availabilityFromJson(String? value) =>
    switch (value) {
      'do_not_disturb' => ColleagueAvailabilityStatus.doNotDisturb,
      'offline' => ColleagueAvailabilityStatus.offline,
      'available' => ColleagueAvailabilityStatus.available,
      'busy' => ColleagueAvailabilityStatus.busy,
      _ => ColleagueAvailabilityStatus.unknown
    };

List<ColleagueContext> _colleagueContextFromJson(List<dynamic> json) => json
    .map(
      (value) => switch (value) {
        'in_call' => const ColleagueContext.inCall(),
        'ringing' => const ColleagueContext.ringing(),
        _ => null
      },
    )
    .whereNotNull()
    .toList();

ColleagueDestinationType _colleagueDestinationTypeFromJson(String? value) =>
    switch (value) {
      'app_account' => ColleagueDestinationType.app,
      'voip_account' => ColleagueDestinationType.voipAccount,
      'fixeddestination' => ColleagueDestinationType.fixed,
      _ => ColleagueDestinationType.none
    };

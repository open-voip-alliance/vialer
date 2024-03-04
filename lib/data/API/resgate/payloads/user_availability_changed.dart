import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vialer/data/API/resgate/payloads/payload.dart';

import '../../../models/relations/colleagues/colleague.dart';

part 'user_availability_changed.freezed.dart';
part 'user_availability_changed.g.dart';

@freezed
class UserAvailabilityChangedPayload
    with _$UserAvailabilityChangedPayload
    implements ResgatePayload {
  const UserAvailabilityChangedPayload._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory UserAvailabilityChangedPayload({
    required String userUuid,
    required bool hasLinkedDestinations,
    required int internalNumber,

    /// This is the inferred status, based on things such as if the user has
    /// a destination set. This is the status that should be used for
    /// colleagues.
    @JsonKey(fromJson: _availabilityFromJson)
    required ColleagueAvailabilityStatus availability,

    /// This is the status that the user has specifically chosen, it should
    /// be the preferred status when showing what the current user has chosen.
    @JsonKey(fromJson: _availabilityFromJson)
    required ColleagueAvailabilityStatus userStatus,
    @JsonKey(fromJson: _colleagueContextFromJson)
    required List<ColleagueContext> context,

    /// The list of selected destinations, currently we only support a single
    /// selected destination but this is a list to future-proof as we plan
    /// to support multiple selected destinations in the future.
    @JsonKey(name: 'destination', fromJson: _selectedDestinationToDestinations)
    @Default([])
    List<SelectedDestination> selectedDestinations,
  }) = _UserAvailabilityChangedPayload;

  SelectedDestination? get selectedDestination =>
      selectedDestinations.firstOrNull;

  factory UserAvailabilityChangedPayload.fromJson(Map<String, dynamic> json) =>
      _$UserAvailabilityChangedPayloadFromJson(json);
}

List<SelectedDestination> _selectedDestinationToDestinations(
  Map<String, dynamic> json,
) =>
    [SelectedDestination.fromJson(json)];

ColleagueAvailabilityStatus _availabilityFromJson(String? value) =>
    switch (value) {
      'do_not_disturb' => ColleagueAvailabilityStatus.doNotDisturb,
      'offline' => ColleagueAvailabilityStatus.offline,
      'available' => ColleagueAvailabilityStatus.available,
      'available_for_colleagues' =>
        ColleagueAvailabilityStatus.availableForColleagues,
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

ColleagueDestinationType _colleagueDestinationTypeFromJson(String type) =>
    switch (type) {
      'app_account' => ColleagueDestinationType.app,
      'voip_account' => ColleagueDestinationType.voipAccount,
      'fixeddestination' => ColleagueDestinationType.fixed,
      _ => ColleagueDestinationType.none
    };

@freezed
class SelectedDestination with _$SelectedDestination {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory SelectedDestination({
    @JsonKey(name: 'portal_id') required int destinationId,
    @JsonKey(name: 'type', fromJson: _colleagueDestinationTypeFromJson)
    required ColleagueDestinationType destinationType,
  }) = _SelectedDestination;

  factory SelectedDestination.fromJson(Map<String, dynamic> json) =>
      _$SelectedDestinationFromJson(json);
}

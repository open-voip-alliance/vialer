import 'package:dartx/dartx.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../app/util/json_converter.dart';
import '../../../app/util/loggable.dart';
import '../../voipgrid/selected_destination_info.dart';
import '../../voipgrid/voipgrid_destination.dart';
import '../../voipgrid/voipgrid_fixed_destination.dart';
import '../../voipgrid/voipgrid_phone_account.dart';
import '../../voipgrid/voipgrid_service.dart';
import 'destination.dart';
import 'destinations.dart';

part 'availability_repository.g.dart';

class AvailabilityRepository with Loggable {
  final VoipgridService _service;

  AvailabilityRepository(this._service);

  Future<Destinations?> getLatestDestinations() async {
    final response = await _service.getAvailability();

    if (!response.isSuccessful) {
      logFailedResponse(response, name: 'Get Latest Availability');
      return null;
    }

    final objects = response.body['objects'] as List<dynamic>? ?? [];

    if (objects.isEmpty) return null;

    return objects
        .map((obj) =>
            _AvailabilityResponse.fromJson(obj as Map<String, dynamic>))
        .toList()
        .first
        .toDestinations();
  }

  Future<bool> setDestination({
    required int selectedDestinationId,
    required Destination destination,
  }) async {
    final response =
        await _service.setAvailability(selectedDestinationId.toString(), {
      'phoneaccount':
          destination is PhoneAccount ? destination.id.toString() : null,
      'fixeddestination':
          destination is PhoneNumber ? destination.id.toString() : null,
    });

    if (!response.isSuccessful) {
      logFailedResponse(response, name: 'Set availability');
    }

    return response.isSuccessful;
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class _AvailabilityResponse {
  @JsonIdConverter()
  final int? id;

  @JsonKey(name: 'fixeddestinations')
  final List<VoipgridFixedDestination> fixedDestinations;

  @JsonKey(name: 'phoneaccounts')
  final List<VoipgridPhoneAccount> phoneAccounts;

  @JsonKey(name: 'selecteduserdestination')
  final SelectedDestinationInfo? selectedDestinationInfo;

  /// Temporarily provide default values to allow for users upgrading from
  /// an older version. defaultValue and includeIfNull can be removed
  /// in the future.
  @JsonKey(defaultValue: 0, includeIfNull: false)
  final int internalNumber;

  VoipgridDestination? get _activeDestination {
    if (selectedDestinationInfo?.phoneAccountId == null &&
        selectedDestinationInfo?.fixedDestinationId == null) {
      return null;
    } else {
      return _voipgridDestinations.firstOrNullWhere(
        (destination) =>
            destination.id == selectedDestinationInfo?.phoneAccountId ||
            destination.id == selectedDestinationInfo?.fixedDestinationId,
      );
    }
  }

  List<VoipgridDestination> get _voipgridDestinations {
    return [
      ...fixedDestinations,
      ...phoneAccounts,
    ];
  }

  const _AvailabilityResponse({
    required this.id,
    required this.fixedDestinations,
    required this.phoneAccounts,
    required this.selectedDestinationInfo,
    required this.internalNumber,
  });

  factory _AvailabilityResponse.fromJson(dynamic json) =>
      _$AvailabilityResponseFromJson(json as Map<String, dynamic>);

  Destinations toDestinations() {
    final activeDestination = _activeDestination;

    return Destinations(
      activeDestination: activeDestination != null
          ? activeDestination.toDestination()
          : const Destination.notAvailable(),
      availableDestinations: _voipgridDestinations
          .map((d) => d.toDestination())
          .prependElement(const Destination.notAvailable())
          .toList(),
      internalNumber: internalNumber,
      selectedDestinationId:
          selectedDestinationInfo!.id, // TODO: allowed / save to do?
    );
  }
}

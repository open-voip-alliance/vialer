import 'package:dartx/dartx.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../app/util/json_converter.dart';
import '../../../app/util/loggable.dart';
import '../../../dependency_locator.dart';
import '../../legacy/storage.dart';
import '../../voipgrid/selected_destination_info.dart';
import '../../voipgrid/voipgrid_destination.dart';
import '../../voipgrid/voipgrid_fixed_destination.dart';
import '../../voipgrid/voipgrid_phone_account.dart';
import '../../voipgrid/voipgrid_service.dart';
import 'destination.dart';

part 'destination_repository.g.dart';

class DestinationRepository with Loggable {
  final _storageRepository = dependencyLocator<StorageRepository>();

  final VoipgridService _service;

  late int selectedUserDestinationId;

  DestinationRepository(this._service);

  Future<Destination> getActiveDestination() async {
    final response = await _service.getAvailability();

    if (!response.isSuccessful) {
      logFailedResponse(response,
          name: 'Get active and available destinations');
      return const Destination.unknown();
    }

    final objects = response.body['objects'] as List<dynamic>? ?? [];

    if (objects.isEmpty) return const Destination.unknown();

    final destinations = objects
        .map(
          (obj) => _AvailabilityResponse.fromJson(obj as Map<String, dynamic>),
        )
        .toList()
        .first;

    _storageRepository.userNumber = destinations.userNumber;
    _storageRepository.availableDestinations = destinations.available;

    selectedUserDestinationId = destinations.selectedDestinationId;

    return destinations.active;
  }

  Future<bool> setDestination({
    required Destination destination,
  }) async {
    final response =
        await _service.setAvailability(selectedUserDestinationId.toString(), {
      'phoneaccount':
          destination is PhoneAccount ? destination.id.toString() : null,
      'fixeddestination':
          destination is PhoneNumber ? destination.id.toString() : null,
    });

    if (!response.isSuccessful) {
      logFailedResponse(response, name: 'Set destination');
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
  @JsonKey(name: 'internal_number', defaultValue: 0, includeIfNull: false)
  final int userNumber;

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
    required this.userNumber,
  });

  Destination get active => _activeDestination != null
      ? _activeDestination!.toDestination()
      : const Destination.notAvailable();

  List<Destination> get available => _voipgridDestinations
      .map((d) => d.toDestination())
      .prependElement(const Destination.notAvailable())
      .toList();

  int get selectedDestinationId => selectedDestinationInfo!.id;

  factory _AvailabilityResponse.fromJson(dynamic json) =>
      _$AvailabilityResponseFromJson(json as Map<String, dynamic>);
}

import 'package:dartx/dartx.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../app/util/json_converter.dart';
import '../../../app/util/loggable.dart';
import '../../user/user.dart';
import '../../voipgrid/selected_destination_info.dart';
import '../../voipgrid/voipgrid_destination.dart';
import '../../voipgrid/voipgrid_fixed_destination.dart';
import '../../voipgrid/voipgrid_phone_account.dart';
import '../../voipgrid/voipgrid_service.dart';

part 'availability_repository.freezed.dart';
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
    // assert(!(phoneAccountId != null && fixedDestinationId != null)); // TODO

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

@freezed
class Destinations with _$Destinations {
  const Destinations._();

  const factory Destinations({
    required Destination activeDestination,
    required List<Destination> availableDestinations,
    required int internalNumber,
    required int selectedDestinationId,
  }) = _Destinations;

  factory Destinations.fromJson(dynamic json) =>
      _$DestinationsFromJson(json as Map<String, dynamic>);

  static Map<String, dynamic> serializeToJson(Destinations destinations) =>
      destinations.toJson();

  List<PhoneAccount> get phoneAccounts => availableDestinations
      .filter((destination) => destination is PhoneAccount)
      .map((destination) => destination as PhoneAccount)
      .toList();

  /// Find the app account for the given user. This should never be null
  /// with a user properly configured for the app.
  PhoneAccount? findAppAccountFor({required User user}) =>
      phoneAccounts.firstOrNullWhere(
        (phoneAccount) => user.appAccountId == phoneAccount.id.toString(),
      );
}

@freezed
class Destination with _$Destination {
  const factory Destination.notAvailable() = NotAvailable;

  // Formally known as FixedDestination.
  const factory Destination.phoneNumber(
    int? id,
    String? description,
    String? phoneNumber,
  ) = PhoneNumber;

  const factory Destination.phoneAccount(
    int? id,
    String description,
    int accountId,
    int internalNumber,
  ) = PhoneAccount;

  factory Destination.fromJson(dynamic json) =>
      _$DestinationFromJson(json as Map<String, dynamic>);
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

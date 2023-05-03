import 'package:dartx/dartx.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../app/util/automatic_retry.dart';
import '../../../app/util/json_converter.dart';
import '../../../app/util/loggable.dart';
import '../../../dependency_locator.dart';
import '../../legacy/storage.dart';
import '../../voipgrid/voipgrid_service.dart';
import 'destination.dart';
import 'selected_destination_info.dart';
import 'voipgrid_destination.dart';
import 'voipgrid_fixed_destination.dart';
import 'voipgrid_phone_account.dart';

part 'destination_repository.g.dart';

class DestinationRepository with Loggable {
  DestinationRepository(this._service);

  final _storageRepository = dependencyLocator<StorageRepository>();

  final VoipgridService _service;
  final automaticRetry = AutomaticRetry.http('Change Destination');

  late int selectedUserDestinationId;

  Future<Destination> getActiveDestination() async {
    final response = await _service.getAvailability();

    if (!response.isSuccessful) {
      logFailedResponse(
        response,
        name: 'Get active and available destinations',
      );
      return const Destination.unknown();
    }

    final objects = response.body?['objects'] as List<dynamic>? ?? <dynamic>[];

    if (objects.isEmpty) return const Destination.unknown();

    final destinations = objects
        .map(
          (dynamic obj) => _AvailabilityResponse.fromJson(
            obj as Map<String, dynamic>,
          ),
        )
        .toList()
        .first;

    _storageRepository
      ..userNumber = destinations.userNumber
      ..availableDestinations = destinations.available;

    selectedUserDestinationId = destinations.selectedDestinationId;

    return destinations.active;
  }

  Future<bool> setDestination({
    required Destination destination,
  }) async {
    try {
      await automaticRetry.run(
        () async {
          final response = await _service.setAvailability(
            selectedUserDestinationId.toString(),
            {
              'phoneaccount': destination is PhoneAccount
                  ? destination.id.toString()
                  : null,
              'fixeddestination':
                  destination is PhoneNumber ? destination.id.toString() : null,
            },
          );

          if (!response.isSuccessful) {
            logFailedResponse(response, name: 'Set destination');
            return AutomaticRetryTaskOutput.success(response);
          }

          return AutomaticRetryTaskOutput.success(response);
        },
      );

      return true;
    } on AutomaticRetryMaximumAttemptsReached {
      return false;
    }
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class _AvailabilityResponse {
  const _AvailabilityResponse({
    required this.id,
    required this.fixedDestinations,
    required this.phoneAccounts,
    required this.selectedDestinationInfo,
    required this.userNumber,
  });

  factory _AvailabilityResponse.fromJson(dynamic json) =>
      _$AvailabilityResponseFromJson(json as Map<String, dynamic>);
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

  Destination get active => _activeDestination != null
      ? _activeDestination!.toDestination()
      : const Destination.notAvailable();

  List<Destination> get available => _voipgridDestinations
      .map((d) => d.toDestination())
      .prependElement(const Destination.notAvailable())
      .toList();

  int get selectedDestinationId => selectedDestinationInfo!.id;
}

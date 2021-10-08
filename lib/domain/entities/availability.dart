import 'package:dartx/dartx.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../app/util/json_converter.dart';
import 'destination.dart';
import 'fixed_destination.dart';
import 'phone_account.dart';
import 'selected_destination_info.dart';
import 'system_user.dart';

part 'availability.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Availability extends Equatable {
  @JsonIdConverter()
  final int? id;

  @JsonKey(name: 'fixeddestinations')
  final List<FixedDestination> fixedDestinations;

  @JsonKey(name: 'phoneaccounts')
  final List<PhoneAccount> phoneAccounts;

  @JsonKey(name: 'selecteduserdestination')
  final SelectedDestinationInfo? selectedDestinationInfo;

  /// Temporarily provide default values to allow for users upgrading from
  /// an older version. defaultValue and includeIfNull can be removed
  /// in the future.
  @JsonKey(name: 'internal_number', defaultValue: 0, includeIfNull: false)
  final int internalNumber;

  Destination? get activeDestination {
    if (selectedDestinationInfo?.phoneAccountId == null &&
        selectedDestinationInfo?.fixedDestinationId == null) {
      return FixedDestination.notAvailable;
    } else {
      return _destinations.firstOrNullWhere(
        (destination) =>
            destination.id == selectedDestinationInfo?.phoneAccountId ||
            destination.id == selectedDestinationInfo?.fixedDestinationId,
      );
    }
  }

  List<Destination> get _destinations {
    return <Destination>[
      ...fixedDestinations,
      ...phoneAccounts,
    ];
  }

  List<Destination> get destinations {
    return [
      FixedDestination.notAvailable,
      ..._destinations,
    ];
  }

  const Availability({
    required this.id,
    required this.fixedDestinations,
    required this.phoneAccounts,
    required this.selectedDestinationInfo,
    required this.internalNumber,
  });

  Availability copyWith({
    int? id,
    List<FixedDestination>? fixedDestinations,
    List<PhoneAccount>? phoneAccounts,
    SelectedDestinationInfo? selectedDestinationInfo,
  }) {
    return Availability(
      id: id ?? this.id,
      fixedDestinations: fixedDestinations ?? this.fixedDestinations,
      phoneAccounts: phoneAccounts ?? this.phoneAccounts,
      selectedDestinationInfo:
          selectedDestinationInfo ?? this.selectedDestinationInfo,
      internalNumber: internalNumber,
    );
  }

  Availability copyWithSelectedDestination({
    required Destination destination,
  }) {
    return copyWith(
      selectedDestinationInfo: selectedDestinationInfo!.replaceDestination(
        destination: destination,
      ),
    );
  }

  /// Find the an app account for the given user. This should never be null
  /// with a user properly configured for the app.
  PhoneAccount? findAppAccountFor({required SystemUser user}) =>
      phoneAccounts.firstOrNullWhere(
        (phoneAccount) => user.appAccountId == phoneAccount.id.toString(),
      );

  @override
  String toString() => '$runtimeType('
      'id: $id, '
      'fixedDestinations: $fixedDestinations, '
      'phoneAccounts: $phoneAccounts, '
      'internalNumber: $internalNumber, '
      'selectedDestinationInfo: $selectedDestinationInfo)';

  factory Availability.fromJson(Map<String, dynamic> json) =>
      _$AvailabilityFromJson(json);

  Map<String, dynamic> toJson() => _$AvailabilityToJson(this);

  @override
  List<Object?> get props => [
        id,
        fixedDestinations,
        phoneAccounts,
        selectedDestinationInfo,
        internalNumber,
      ];
}

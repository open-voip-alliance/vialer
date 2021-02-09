import 'package:dartx/dartx.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../app/util/json_converter.dart';

import 'destination.dart';
import 'fixed_destination.dart';
import 'phone_account.dart';
import 'selected_destination_info.dart';

part 'availability.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Availability extends Equatable {
  @JsonIdConverter()
  final int id;

  @JsonKey(name: 'fixeddestinations')
  final List<FixedDestination> fixedDestinations;

  @JsonKey(name: 'phoneaccounts')
  final List<PhoneAccount> phoneAccounts;

  @JsonKey(name: 'selecteduserdestination')
  final SelectedDestinationInfo selectedDestinationInfo;

  Destination get activeDestination {
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
      ...fixedDestinations ?? [],
      ...phoneAccounts ?? [],
    ];
  }

  List<Destination> get destinations {
    return [
      FixedDestination.notAvailable,
      ..._destinations,
    ];
  }

  const Availability({
    this.id,
    this.fixedDestinations,
    this.phoneAccounts,
    this.selectedDestinationInfo,
  });

  Availability copyWith({
    int id,
    List<FixedDestination> fixedDestinations,
    List<PhoneAccount> phoneAccounts,
    SelectedDestinationInfo selectedDestinationInfo,
  }) {
    return Availability(
      id: id ?? this.id,
      fixedDestinations: fixedDestinations ?? this.fixedDestinations,
      phoneAccounts: phoneAccounts ?? this.phoneAccounts,
      selectedDestinationInfo:
          selectedDestinationInfo ?? this.selectedDestinationInfo,
    );
  }

  Availability copyWithSelectedDestination({
    @required Destination destination,
  }) {
    return copyWith(
      selectedDestinationInfo: selectedDestinationInfo.replaceDestination(
        destination: destination,
      ),
    );
  }

  @override
  String toString() => '$runtimeType('
      'id: $id, '
      'fixedDestinations: $fixedDestinations, '
      'phoneAccounts: $phoneAccounts, '
      'selectedDestinationInfo: $selectedDestinationInfo)';

  factory Availability.fromJson(Map<String, dynamic> json) =>
      _$AvailabilityFromJson(json);

  Map<String, dynamic> toJson() => _$AvailabilityToJson(this);

  @override
  List<Object> get props => [
        id,
        fixedDestinations,
        phoneAccounts,
        selectedDestinationInfo,
      ];
}

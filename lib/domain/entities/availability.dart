import 'package:dartx/dartx.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../app/util/json_converter.dart';

import 'destination.dart';
import 'fixed_destination.dart';
import 'phone_account.dart';
import 'selected_user_destination.dart';

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
  final SelectedDestination selectedDestination;

  Destination get activeDestination {
    if (selectedDestination?.phoneAccountId == null &&
        selectedDestination?.fixedDestinationId == null) {
      return FixedDestination.notAvailable;
    } else {
      return _destinations.firstOrNullWhere((destination) =>
          destination.id == selectedDestination?.phoneAccountId ||
          destination.id == selectedDestination?.fixedDestinationId);
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

  @override
  String toString() => '$id, \n'
      'fixed destinations: $fixedDestinations, \n'
      'phone accounts: $phoneAccounts, \n'
      'selected destination: $selectedDestination';

  const Availability({
    this.id,
    this.fixedDestinations,
    this.phoneAccounts,
    this.selectedDestination,
  });

  Availability copyWith({
    int id,
    List<FixedDestination> fixedDestinations,
    List<PhoneAccount> phoneAccounts,
    SelectedDestination selectedDestination,
  }) {
    return Availability(
      id: id ?? this.id,
      fixedDestinations: fixedDestinations ?? this.fixedDestinations,
      phoneAccounts: phoneAccounts ?? this.phoneAccounts,
      selectedDestination: selectedDestination ?? this.selectedDestination,
    );
  }

  Availability copyWithSelectedDestination({
    @required Destination destination,
  }) {
    return copyWith(
      selectedDestination: selectedDestination.replaceDestination(
        destination: destination,
      ),
    );
  }

  factory Availability.fromJson(Map<String, dynamic> json) =>
      _$AvailabilityFromJson(json);

  Map<String, dynamic> toJson() => _$AvailabilityToJson(this);

  @override
  List<Object> get props => [
        id,
        fixedDestinations,
        phoneAccounts,
        selectedDestination,
      ];
}

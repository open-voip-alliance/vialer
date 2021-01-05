import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';

import 'destination.dart';
import 'fixed_destination.dart';
import 'phone_account.dart';

part 'selected_user_destination.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class SelectedDestination extends Destination {
  @override
  final int id;

  @JsonKey(name: 'fixeddestination')
  final int fixedDestinationId;

  @JsonKey(name: 'phoneaccount')
  final int phoneAccountId;

  const SelectedDestination({
    this.id,
    this.fixedDestinationId,
    this.phoneAccountId,
  });

  SelectedDestination copyWith({
    int id,
    int fixedDestinationId,
    int phoneAccountId,
  }) {
    return SelectedDestination(
      id: id ?? this.id,
      fixedDestinationId: fixedDestinationId ?? this.fixedDestinationId,
      phoneAccountId: phoneAccountId ?? this.phoneAccountId,
    );
  }

  SelectedDestination replaceDestination({
    @required Destination destination,
  }) {
    return SelectedDestination(
      id: id,
      fixedDestinationId:
          (destination is FixedDestination) ? destination.id : null,
      phoneAccountId: (destination is PhoneAccount) ? destination.id : null,
    );
  }

  factory SelectedDestination.fromJson(Map<String, dynamic> json) =>
      _$SelectedDestinationFromJson(json);

  Map<String, dynamic> toJson() => _$SelectedDestinationToJson(this);

  @override
  String toString() => '$runtimeType('
      'id: $id, '
      'fixed destination: $fixedDestinationId, '
      'phone account: $phoneAccountId)';

  @override
  List<Object> get props => [
        ...super.props,
        id,
        fixedDestinationId,
        phoneAccountId,
      ];
}

import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:voip_flutter_integration/util/equatable.dart';

import 'destination.dart';
import 'fixed_destination.dart';
import 'phone_account.dart';

part 'selected_destination_info.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class SelectedDestinationInfo extends Equatable {
  final int id;

  @JsonKey(name: 'fixeddestination')
  final int fixedDestinationId;

  @JsonKey(name: 'phoneaccount')
  final int phoneAccountId;

  const SelectedDestinationInfo({
    this.id,
    this.fixedDestinationId,
    this.phoneAccountId,
  });

  SelectedDestinationInfo copyWith({
    int id,
    int fixedDestinationId,
    int phoneAccountId,
  }) {
    return SelectedDestinationInfo(
      id: id ?? this.id,
      fixedDestinationId: fixedDestinationId ?? this.fixedDestinationId,
      phoneAccountId: phoneAccountId ?? this.phoneAccountId,
    );
  }

  SelectedDestinationInfo replaceDestination({
    @required Destination destination,
  }) {
    return SelectedDestinationInfo(
      id: id,
      fixedDestinationId:
          (destination is FixedDestination) ? destination.id : null,
      phoneAccountId: (destination is PhoneAccount) ? destination.id : null,
    );
  }

  factory SelectedDestinationInfo.fromJson(Map<String, dynamic> json) =>
      _$SelectedDestinationInfoFromJson(json);

  Map<String, dynamic> toJson() => _$SelectedDestinationInfoToJson(this);

  @override
  String toString() => '$runtimeType('
      'id: $id, '
      'fixedDestinationId: $fixedDestinationId, '
      'phoneAccountId: $phoneAccountId)';

  @override
  List<Object> get props => [
        id,
        fixedDestinationId,
        phoneAccountId,
      ];
}

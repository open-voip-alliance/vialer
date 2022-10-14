import 'package:json_annotation/json_annotation.dart';

import '../../app/util/json_converter.dart';
import 'destination.dart';

part 'fixed_destination.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class FixedDestination extends Destination {
  static const notAvailable = FixedDestination();

  @override
  @JsonIdConverter()
  final int? id;

  @JsonKey(name: 'phonenumber', fromJson: _normalizedPhoneNumber)
  final String? phoneNumber;

  @override
  final String? description;

  static String _normalizedPhoneNumber(String json) =>
      json.startsWith('+') ? json : '+$json';

  const FixedDestination({
    this.id,
    this.phoneNumber,
    this.description,
  });

  FixedDestination copyWith({
    int? id,
    String? phoneNumber,
    String? description,
  }) {
    return FixedDestination(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      description: description ?? this.description,
    );
  }

  factory FixedDestination.fromJson(Map<String, dynamic> json) =>
      _$FixedDestinationFromJson(json);

  Map<String, dynamic> toJson() => _$FixedDestinationToJson(this);

  @override
  String toString() => '$runtimeType(id: $id, $phoneNumber, $description)';

  @override
  List<Object?> get props => [...super.props, id, phoneNumber, description];
}

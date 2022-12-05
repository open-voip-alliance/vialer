import 'package:json_annotation/json_annotation.dart';

import '../../app/util/json_converter.dart';
import '../calling/voip/destination.dart';
import 'voipgrid_destination.dart';

part 'voipgrid_fixed_destination.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class VoipgridFixedDestination extends VoipgridDestination {
  @override
  @JsonIdConverter()
  final int? id;

  @JsonKey(name: 'phonenumber', fromJson: _normalizedPhoneNumber)
  final String? phoneNumber;

  @override
  final String? description;

  static String _normalizedPhoneNumber(String json) =>
      json.startsWith('+') ? json : '+$json';

  const VoipgridFixedDestination({
    this.id,
    this.phoneNumber,
    this.description,
  });

  factory VoipgridFixedDestination.fromJson(Map<String, dynamic> json) =>
      _$VoipgridFixedDestinationFromJson(json);

  @override
  Destination toDestination() => Destination.phoneNumber(
        id,
        description,
        phoneNumber,
      );
}

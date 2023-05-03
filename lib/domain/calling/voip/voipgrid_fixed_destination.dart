import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../app/util/json_converter.dart';
import 'destination.dart';
import 'voipgrid_destination.dart';

part 'voipgrid_fixed_destination.freezed.dart';

part 'voipgrid_fixed_destination.g.dart';

@freezed
class VoipgridFixedDestination extends VoipgridDestination
    with _$VoipgridFixedDestination {
  const factory VoipgridFixedDestination({
    @override @JsonIdConverter() int? id,
    @JsonKey(name: 'phonenumber', fromJson: _normalizedPhoneNumber)
        String? phoneNumber,
    @override String? description,
  }) = _VoipgridFixedDestination;

  const VoipgridFixedDestination._();

  factory VoipgridFixedDestination.fromJson(Map<String, dynamic> json) =>
      _$VoipgridFixedDestinationFromJson(json);

  @override
  Destination toDestination() => Destination.phoneNumber(
        id,
        description,
        phoneNumber,
      );
}

String _normalizedPhoneNumber(String json) =>
    json.startsWith('+') ? json : '+$json';

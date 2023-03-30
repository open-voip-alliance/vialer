import 'package:freezed_annotation/freezed_annotation.dart';

import 'colleague.dart';

part 'availbility_update.freezed.dart';

@freezed
class AvailabilityUpdate with _$AvailabilityUpdate {
  const factory AvailabilityUpdate({
    required ColleagueAvailabilityStatus availabilityStatus,
    required List<ColleagueContext> context,
    required String internalNumber,
    required ColleagueDestination destination,
  }) = _AvailabilityUpdate;
}

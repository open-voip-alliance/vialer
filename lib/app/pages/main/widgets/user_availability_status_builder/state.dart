import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vialer/domain/calling/voip/destination.dart';

import '../../../../../domain/relations/user_availability_status.dart';

part 'state.freezed.dart';

@freezed
class UserAvailabilityStatusState with _$UserAvailabilityStatusState {
  const factory UserAvailabilityStatusState({
    required UserAvailabilityStatus status,
    Destination? currentDestination,
    @Default([]) List<Destination> availableDestinations,
    @Default(false) bool isRingingDeviceOffline,
  }) = _UserAvailabilityStatusState;
}

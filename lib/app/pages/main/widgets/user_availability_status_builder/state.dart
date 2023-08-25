import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../domain/relations/user_availability_status.dart';

part 'state.freezed.dart';

@freezed
class UserAvailabilityStatusState with _$UserAvailabilityStatusState {
  const factory UserAvailabilityStatusState({
    required UserAvailabilityStatus status,
  }) = _UserAvailabilityStatusState;
}

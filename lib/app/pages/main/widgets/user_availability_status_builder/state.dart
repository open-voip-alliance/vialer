import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../domain/user_availability/colleagues/colleague.dart';

part 'state.freezed.dart';

@freezed
class UserAvailabilityStatusState with _$UserAvailabilityStatusState {
  const factory UserAvailabilityStatusState({
    required ColleagueAvailabilityStatus status,
  }) = _UserAvailabilityStatusState;
}

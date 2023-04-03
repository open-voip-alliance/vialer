import 'package:freezed_annotation/freezed_annotation.dart';

import '../../user_availability/colleagues/availbility_update.dart';

part 'logged_in_user_availability_changed.freezed.dart';

/// We've received an availability update for the logged-in user.
@freezed
class LoggedInUserAvailabilityChanged with _$LoggedInUserAvailabilityChanged {
  const factory LoggedInUserAvailabilityChanged({
    required AvailabilityUpdate availability,
  }) = _LoggedInUserAvailabilityChanged;
}
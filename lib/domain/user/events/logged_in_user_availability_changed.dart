import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vialer/domain/relations/user_availability_status.dart';

import '../../event/event_bus.dart';
import '../../relations/websocket/payloads/user_availability_changed.dart';

part 'logged_in_user_availability_changed.freezed.dart';

/// We've received an availability update for the logged-in user.
@freezed
class LoggedInUserAvailabilityChanged
    with _$LoggedInUserAvailabilityChanged
    implements EventBusEvent {
  const factory LoggedInUserAvailabilityChanged({
    required UserAvailabilityChangedPayload availability,
    required UserAvailabilityStatus userAvailabilityStatus,
  }) = _LoggedInUserAvailabilityChanged;
}

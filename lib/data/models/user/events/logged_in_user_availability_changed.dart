import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vialer/data/models/relations/user_availability_status.dart';

import '../../../API/resgate/payloads/user_availability_changed.dart';
import '../../event/event_bus.dart';

part 'logged_in_user_availability_changed.freezed.dart';

/// We've received an availability update for the logged-in user.
@freezed
class LoggedInUserAvailabilityChanged
    with _$LoggedInUserAvailabilityChanged
    implements EventBusEvent {
  const factory LoggedInUserAvailabilityChanged({
    required UserAvailabilityChangedPayload availability,
    required UserAvailabilityStatus userAvailabilityStatus,
    required bool isRingingDeviceOffline,
  }) = _LoggedInUserAvailabilityChanged;
}

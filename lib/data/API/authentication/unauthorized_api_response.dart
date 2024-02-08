import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/event/event_bus.dart';

part 'unauthorized_api_response.freezed.dart';

/// An unauthorized (typically 401) response was received when attempting to
/// contact the API.
@freezed
class UnauthorizedApiResponseEvent
    with _$UnauthorizedApiResponseEvent
    implements EventBusEvent {
  const factory UnauthorizedApiResponseEvent({
    /// The url that was being queried that triggered the event.
    required String url,

    /// The status code that caused the user to appear as unauthorized.
    required int statusCode,
  }) = _UnauthorizedApiResponseEvent;
}

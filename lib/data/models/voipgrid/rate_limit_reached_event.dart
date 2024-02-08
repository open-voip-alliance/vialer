import 'package:freezed_annotation/freezed_annotation.dart';

import '../event/event_bus.dart';

part 'rate_limit_reached_event.freezed.dart';

@freezed
class RateLimitReachedEvent
    with _$RateLimitReachedEvent
    implements EventBusEvent {
  const factory RateLimitReachedEvent({
    required String url,
    required DateTime hitLimitAt,
  }) = _RateLimitReachedEvent;
}

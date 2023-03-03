import 'package:freezed_annotation/freezed_annotation.dart';

part 'rate_limit_reached_event.freezed.dart';

@freezed
class RateLimitReachedEvent with _$RateLimitReachedEvent {
  const factory RateLimitReachedEvent({
    required String url,
    required DateTime hitLimitAt,
  }) = _RateLimitReachedEvent;
}

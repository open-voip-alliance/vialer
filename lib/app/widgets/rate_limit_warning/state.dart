import 'package:freezed_annotation/freezed_annotation.dart';

part 'state.freezed.dart';

@freezed
class RateLimitWarningState with _$RateLimitWarningState {
  const factory RateLimitWarningState.limited(String url) = RateLimited;
  const factory RateLimitWarningState.none() = NoRateLimit;
}

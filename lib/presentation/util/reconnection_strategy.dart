import 'dart:math';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'reconnection_strategy.freezed.dart';

class ReconnectionStrategy {
  ReconnectionStrategy(this.params) {
    _createSchedule();
  }

  static ReconnectionStrategy defaultStrategy = ReconnectionStrategy(
    const RetryPattern(
      initialDelay: Duration(seconds: 10),
      jitter: true,
    ),
  );

  int attempts = 0;
  late final List<Duration> schedule;

  final RetryPattern params;

  void increment({int amount = 1}) => attempts += amount;

  void reset() => attempts = 0;

  Duration delayFor() =>
      attempts < schedule.length ? schedule[attempts] : schedule.last;

  void _createSchedule() {
    schedule = List.generate(params.maxBackOff, (attempt) {
      final initial = params.initialDelay;
      var seconds = initial.inSeconds.toDouble();

      for (var i = 1; i <= attempt; i++) {
        seconds = seconds * params.backOff;
      }

      if (params.jitter) {
        final jitterPercentage =
            Random().nextInt(params.jitterMaxPercent) + 100;
        seconds = seconds * (jitterPercentage / 100);
      }

      return Duration(milliseconds: (seconds * 1000).toInt());
    });
  }
}

@freezed
class RetryPattern with _$RetryPattern {
  const factory RetryPattern({
    /// The initial delay, before this no retry attempts are made
    /// and future attempts are based on mutating this value.
    required Duration initialDelay,

    /// The amount to back off, every time a new retry is made, the next delay
    /// will be incremented by this amount as a percentage of the previous
    /// retry delay.
    ///
    /// So the first retry will be [initialDelay], the second retry will be
    /// first retry * [backOff], the third retry will be second retry *
    /// [backOff].
    @Default(1.25) double backOff,

    /// The maximum amount of times before we no longer back off any further
    /// and just continue using the last value for future retries.
    @Default(10) int maxBackOff,

    /// Applies "jitter" which is a random value that is added to each delay
    /// that can be used to off-set requests between multiple clients.
    @Default(false) bool jitter,

    /// The maximum bounds of this jitter, so setting it to a value of [30]
    /// will increment the delay anywhere between 0 and 30%.
    ///
    /// If [jitter] is false, this has no effect.
    @Default(30) int jitterMaxPercent,
  }) = _RetryPattern;

  const RetryPattern._();
}

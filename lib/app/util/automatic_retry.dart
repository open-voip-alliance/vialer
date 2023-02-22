import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';

import 'loggable.dart';

part 'automatic_retry.freezed.dart';

class AutomaticRetry with Loggable {
  final _timers = <Timer>[];

  /// The [schedule] provided is relative to the first time it is run, not the
  /// previous retry attempt.
  final List<Duration> schedule;

  /// If a name is provided, logging will be performed when the task fails.
  final String? name;

  AutomaticRetry({required this.schedule, this.name});

  factory AutomaticRetry.http(String name) => AutomaticRetry(
        schedule: RetrySchedule.http,
        name: name,
      );

  /// Will automatically retry the provided task, according to the given
  /// schedule.
  ///
  /// If every run in the schedule fails, [AutomaticRetryMaximumAttemptsReached]
  /// will be thrown.
  ///
  /// Set [runImmediately] to [false] for the first attempt to occur at the
  /// first entry in the schedule, rather than immediately.
  Future<T> run<T>(
    Future<AutomaticRetryTaskOutput<T>> Function() task, {
    bool runImmediately = true,
  }) async {
    _timers.cancelAll();

    if (!runImmediately && schedule.isEmpty) {
      throw ArgumentError(
        'You must either provide a schedule, or enable run immediately, '
        'otherwise nothing will ever execute.',
      );
    }

    if (runImmediately) {
      final output = await task();

      if (output.result == AutomaticRetryTaskResult.success) {
        return output.data as T;
      }

      if (schedule.isEmpty) {
        _logTaskAsFailed(immediate: true);
        throw AutomaticRetryMaximumAttemptsReached();
      }
    }

    final completer = Completer<T>();

    _scheduleTimers<T>(task, completer);

    return completer.future;
  }

  void _scheduleTimers<T>(
    Future<dynamic> Function() task,
    Completer<dynamic> completer,
  ) {
    for (var duration in schedule) {
      final timer = Timer(duration, () async {
        final output = await task();
        if (output.result == AutomaticRetryTaskResult.success) {
          _timers.cancelAll();
          return completer.complete(output.data as T);
        } else {
          if (!_timers.hasAnyActive) {
            completer.completeError(AutomaticRetryMaximumAttemptsReached());
            _logTaskAsFailed();
            return;
          }
        }
      });

      _timers.add(timer);
    }
  }

  void _logTaskAsFailed({bool immediate = false}) {
    if (name != null) {
      final attempts = immediate ? 1 : schedule.length + 1;

      logger.warning(
        'AutomaticRetryTask [$name] has failed after [$attempts] attempts.',
      );
    }
  }
}

extension on List<Timer> {
  void cancelAll() {
    forEach((timer) => timer.cancel());
    clear();
  }

  bool get hasAnyActive => where((timer) => timer.isActive).isNotEmpty;
}

/// Indicates that the retry task has reached the maximum number of attempts
/// and will stop trying any further.
class AutomaticRetryMaximumAttemptsReached implements Exception {}

class RetrySchedule {
  /// This is a sensible default schedule for http requests, for other uses
  /// you likely want to use a custom schedule.
  static const http = [
    Duration(seconds: 1),
    Duration(seconds: 3),
    Duration(seconds: 5),
  ];
}

/// Contains the result of an individual task, the task must provide both the
/// [AutomaticRetryTaskResult] and the data that it should output.
@freezed
class AutomaticRetryTaskOutput<T> with _$AutomaticRetryTaskOutput {
  const factory AutomaticRetryTaskOutput({
    required T data,
    required AutomaticRetryTaskResult result,
  }) = _AutomaticRetryTaskOutput;

  factory AutomaticRetryTaskOutput.success(T data) => AutomaticRetryTaskOutput(
        data: data,
        result: AutomaticRetryTaskResult.success,
      );

  factory AutomaticRetryTaskOutput.fail(T data) => AutomaticRetryTaskOutput(
        data: data,
        result: AutomaticRetryTaskResult.fail,
      );
}

enum AutomaticRetryTaskResult {
  success,
  fail,
}

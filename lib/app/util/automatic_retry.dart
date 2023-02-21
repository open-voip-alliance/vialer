import 'dart:async';

import 'loggable.dart';

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
  /// The task MUST throw a [TaskFailedQueueForRetry] exception to indicate
  /// that the task failed, otherwise it will be assumed that it succeeded.
  ///
  /// If every run in the schedule fails, [AutomaticRetryMaximumAttemptsReached]
  /// will be thrown.
  ///
  /// Set [runImmediately] to [false] for the first attempt to occur at the
  /// first entry in the schedule, rather than immediately.
  Future<T> run<T>(
    Future<T> Function() task, {
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
      try {
        return await task();
      } on TaskFailedQueueForRetry {
        if (schedule.isEmpty) {
          _logTaskAsFailed();
          throw AutomaticRetryMaximumAttemptsReached();
        }
      }
    }

    final completer = Completer<T>();

    _scheduleTimers(task, completer);

    return completer.future;
  }

  void _scheduleTimers(
    Future<dynamic> Function() task,
    Completer<dynamic> completer,
  ) {
    for (var duration in schedule) {
      final timer = Timer(
        duration,
        () async {
          try {
            final result = await task();
            _timers.cancelAll();
            return completer.complete(result);
          } on TaskFailedQueueForRetry {
            if (!_timers.hasAnyActive) {
              completer.completeError(AutomaticRetryMaximumAttemptsReached());
              _logTaskAsFailed();
              return;
            }
          }
        },
      );

      _timers.add(timer);
    }
  }

  void _logTaskAsFailed() {
    if (name != null) {
      logger.warning(
        'AutomaticRetryTask [$name] has failed after ${schedule.length + 1} '
        'attempts.',
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

/// The exception that any task must throw to indicate that it has failed.
class TaskFailedQueueForRetry implements Exception {}

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

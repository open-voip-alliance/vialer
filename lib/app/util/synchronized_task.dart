import 'dart:async';

import 'loggable.dart';

/// Wraps a task that should only be executed one at a time.
class SynchronizedTask<T> with Loggable {
  /// A unique identifier for this task, a matching task is what defines
  /// if it is running.
  final String name;

  final SynchronizedTaskMode mode;

  /// The map of running tasks, if the name of this task is in this map
  /// it means it is running.
  ///
  /// The name maps to a [Completer] which will be notified when the logic
  /// has completed.
  static final _runningTasks = <String, Completer>{};

  SynchronizedTask._(this.name, this.mode);

  factory SynchronizedTask.named(
    String name, [
    SynchronizedTaskMode mode = SynchronizedTaskMode.single,
  ]) =>
      SynchronizedTask._(name, mode);

  /// Generate a named task based on the name of the class being passed into,
  /// this makes it cleaner to generate a [SynchronizedTask] that matches
  /// the class you are currently working in.
  factory SynchronizedTask.of(
    dynamic name, [
    SynchronizedTaskMode mode = SynchronizedTaskMode.single,
  ]) =>
      SynchronizedTask.named(name.runtimeType.toString());

  Future<T> run(Future<T> Function() task) async {
    final runningTask = _runningTasks[name];
    if (runningTask != null) {
      final future = runningTask.future;
      switch (mode) {
        case SynchronizedTaskMode.single:
          logger.info('Unable to start [$name] as it is already running.');
          return future as Future<T>;
        case SynchronizedTaskMode.queue:
          logger.info('Waiting for [$name] as it is already running.');
          await future;
          break;
      }
    }

    final completer = Completer<T>();
    _runningTasks[name] = completer;

    try {
      final result = await task();
      // The task must be removed before completing, otherwise a new queued
      // task could already have been inserted which then gets
      // removed immediately.
      _runningTasks.remove(name);
      completer.complete(result);
      return result;
    } on Exception {
      _runningTasks.remove(name);
      rethrow;
    }
  }
}

enum SynchronizedTaskMode {
  /// If a task is already running with the same `name`, it will await
  /// that task instead of starting a new one.
  ///
  /// If using this mode, the type of the task **must** be the same for all
  /// tasks with that name.
  single,

  /// If a task is already running with the same `name`, it will await
  /// that task and then start a new one.
  queue,
}

const editUserTask = 'EditUser';

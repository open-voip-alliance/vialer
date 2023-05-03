import 'dart:async';

import 'package:synchronized/synchronized.dart';

import 'loggable.dart';

/// Wraps a task that should only be executed one at a time.
class SynchronizedTask<T> with Loggable {
  SynchronizedTask._(this.name, this.mode);

  factory SynchronizedTask.named(
    String name, [
    SynchronizedTaskMode mode = SynchronizedTaskMode.single,
  ]) =>
      SynchronizedTask._(name, mode);

  /// Generate a named task based on the name of the class being passed into,
  /// this makes it cleaner to generate a [SynchronizedTask] that matches
  /// the class you are currently working in.
  factory SynchronizedTask.of(dynamic name) =>
      SynchronizedTask.named(name.runtimeType.toString());

  /// A unique identifier for this task, a matching task is what defines
  /// if it is running.
  final String name;

  final SynchronizedTaskMode mode;

  /// The map of running single ([SynchronizedTaskMode.single]) tasks,
  /// if the name of this task is in this map it means it is running.
  ///
  /// The name maps to a [Completer] which will be notified when the logic
  /// has completed.
  static final _runningSingleTasks = <String, Completer<void>>{};

  /// The map of locks associated by [name]. The lock is used while running
  /// a task, making sure they are properly queued.
  static final _queueTaskLocks = <String, Lock>{};

  Future<T> run(Future<T> Function() task) async {
    switch (mode) {
      case SynchronizedTaskMode.single:
        return _runSingleTask(task);
      case SynchronizedTaskMode.queue:
        return _runQueueTask(task);
    }
  }

  Future<T> _runSingleTask(Future<T> Function() task) async {
    final runningTask = _runningSingleTasks[name];
    if (runningTask != null) {
      logger.info('Unable to start [$name] as it is already running.');
      return runningTask.future as Future<T>;
    }

    final completer = Completer<T>();
    _runningSingleTasks[name] = completer;

    try {
      final result = await task();
      completer.complete(result);
      return result;
    } finally {
      _runningSingleTasks.remove(name);
    }
  }

  Future<T> _runQueueTask(Future<T> Function() task) {
    final lock = _queueTaskLocks[name] ??= Lock();
    return lock.synchronized(task);
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

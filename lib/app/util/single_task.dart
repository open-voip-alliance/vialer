import 'loggable.dart';

typedef Task = Future<void> Function();

/// Wraps a task that should only be executed once at a time.
class SingleInstanceTask with Loggable {
  /// A unique identifier for this task, a matching task is what defines
  /// if it is running.
  final String name;

  /// The list of running tasks, if the name of this task appears in the list
  /// it means it is running.
  static final _runningTasks = <String>[];

  SingleInstanceTask._(this.name);

  factory SingleInstanceTask.named(String name) => SingleInstanceTask._(name);

  Future<void> run(Task task) async {
    if (_runningTasks.contains(name)) {
      logger.info('Unable to start [$name] as it is already running.');
      return;
    }

    _runningTasks.add(name);
    await task();
    _runningTasks.remove(name);
  }
}

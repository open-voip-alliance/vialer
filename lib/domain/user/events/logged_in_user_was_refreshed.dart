import 'package:freezed_annotation/freezed_annotation.dart';

import '../refresh/user_refresh_task.dart';
import '../user.dart';

part 'logged_in_user_was_refreshed.freezed.dart';

@freezed
class LoggedInUserWasRefreshed with _$LoggedInUserWasRefreshed {
  const LoggedInUserWasRefreshed._();

  const factory LoggedInUserWasRefreshed({
    required User current,
    required User previous,

    /// The [UserRefreshTask]s that were actually run when the logged-in user
    /// was refreshed.
    required List<UserRefreshTask> tasksPerformed,

    /// Whether this was the first time we fetched the user or not.
    required bool isFirstTime,
  }) = _LoggedInUserWasRefreshed;

  /// Check if a specific [UserRefreshTask] was performed when this event was
  /// broadcast, this way if you only care about (e.g.) the user's destination
  /// potentially changing you can check if we performed
  /// [UserRefreshTask.userDestination].
  bool didPerform(UserRefreshTask task) => tasksPerformed.contains(task);
}

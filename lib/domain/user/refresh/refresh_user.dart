import 'dart:async';

import 'package:vialer/domain/authentication/user_logged_in.dart';
import 'package:vialer/domain/user/settings/settings_repository.dart';

import '../../../app/util/loggable.dart';
import '../../../app/util/synchronized_task.dart';
import '../../../dependency_locator.dart';
import '../../authentication/authentication_repository.dart';
import '../../event/event_bus.dart';
import '../../legacy/storage.dart';
import '../../onboarding/exceptions.dart';
import '../../onboarding/login_credentials.dart';
import '../../use_case.dart';
import '../events/logged_in_user_was_refreshed.dart';
import '../user.dart';
import 'user_refresh_task.dart';
import 'user_refresh_task_performer.dart';

class RefreshUser extends UseCase with Loggable {
  final _storageRepository = dependencyLocator<StorageRepository>();
  final _settings = dependencyLocator<SettingsRepository>();
  final _auth = dependencyLocator<AuthRepository>();
  final _eventBus = dependencyLocator<EventBus>();

  Future<User?> call({
    required List<UserRefreshTask> tasksToPerform,
    LoginCredentials? credentials,
    bool synchronized = true,
  }) {
    Future<User?> refreshUser() => _refreshUser(credentials, tasksToPerform);

    return synchronized
        ? SynchronizedTask<User?>.named(
            editUserTask,
            SynchronizedTaskMode.queue,
          ).run(refreshUser)
        : refreshUser();
  }

  Future<User?> _getUser(LoginCredentials? credentials) async {
    try {
      return _auth.getUserFromCredentials(credentials);
    } on FailedToRetrieveUserException {
      return null;
    }
  }

  Future<User?> _refreshUser(
    LoginCredentials? credentials,
    List<UserRefreshTask> tasksToPerform,
  ) async {
    Future<User?> executeUserRefreshTasks() async {
      final storedUser = _storageRepository.user;
      final latestUser = tasksToPerform.contains(UserRefreshTask.userCore) ||
              storedUser == null
          ? await _getUser(credentials)
          : storedUser;

      if (latestUser == null) return storedUser;

      // Latest user contains some settings, such as mobile and
      // outgoing number.
      var user = storedUser?.copyFrom(latestUser) ?? latestUser;

      user = user.copyWith(
        permissions: storedUser?.permissions,
        client: storedUser?.client,
        voip: () => storedUser?.appAccount,
      );

      final isFirstTime = storedUser == null;

      if (isFirstTime) {
        user = await _performFirstTimeTasks(user);
      } else {
        // If it's the first time logging in then we will apply these
        // during the login process.
        await _settings.applyDefaultSettings();
      }

      final previous = user;

      user = await tasksToPerform
          .performInParallel(user)
          .then((userMutators) => userMutators.mutateInSequence(user));

      _storageRepository.user = user;

      _eventBus.broadcast(
        isFirstTime
            ? UserLoggedIn(user: user)
            : LoggedInUserWasRefreshed(
                current: user,
                previous: previous,
                tasksPerformed: tasksToPerform,
                isFirstTime: isFirstTime,
              ),
      );

      return user;
    }

    /// If there aren't many tasks in this list we will always execute
    /// immediately rather than managing synchronization.
    return tasksToPerform.shouldSkipSynchronization
        ? executeUserRefreshTasks()
        : SynchronizedTask<User?>.of(this).run(executeUserRefreshTasks);
  }

  /// Performs some tasks that are required when we are first setting up a user.
  Future<User> _performFirstTimeTasks(User user) async {
    // Setting the user so it can be used for requests
    _storageRepository.user = user;

    // Fetching the permissions first so future tasks will have know what they
    // have access to
    final mutator =
        await UserRefreshTask.voipgridUserPermissions.performer!.call(user);

    return mutator(user);
  }
}

extension on List<UserRefreshTask> {
  bool get shouldSkipSynchronization => length <= 2;

  Future<List<UserMutator>> performInParallel(User user) => Future.wait(
        map(
          (task) async {
            final performer = task.performer;

            if (performer != null) return performer(user);

            return unmutatedUser;
          },
        ),
      );
}

extension on List<UserMutator> {
  User mutateInSequence(User user) =>
      fold(user, (user, userMutator) => userMutator(user));
}

import 'dart:async';

import '../../../app/util/loggable.dart';
import '../../../app/util/synchronized_task.dart';
import '../../../dependency_locator.dart';
import '../../authentication/authentication_repository.dart';
import '../../event/event_bus.dart';
import '../../legacy/storage.dart';
import '../../onboarding/login_credentials.dart';
import '../../use_case.dart';
import '../events/logged_in_user_was_refreshed.dart';
import '../settings/settings.dart';
import '../user.dart';
import 'user_refresh_task.dart';
import 'user_refresh_task_performer.dart';

class RefreshUser extends UseCase with Loggable {
  final _storageRepository = dependencyLocator<StorageRepository>();
  final _auth = dependencyLocator<AuthRepository>();
  final _eventBus = dependencyLocator<EventBus>();

  Future<User?> call({
    LoginCredentials? credentials,
    bool synchronized = true,
    required List<UserRefreshTask> tasksToPerform,
  }) {
    Future<User?> refreshUser() => _refreshUser(credentials, tasksToPerform);

    return synchronized
        ? SynchronizedTask<User?>.named(
            editUserTask,
            SynchronizedTaskMode.queue,
          ).run(refreshUser)
        : refreshUser();
  }

  Future<User?> _refreshUser(
    LoginCredentials? credentials,
    List<UserRefreshTask> tasksToPerform,
  ) async {
    Future<User?> executeUserRefreshTasks() async {
      final storedUser = _storageRepository.user;
      final latestUser = await _auth.getUserFromCredentials(credentials);

      if (latestUser == null) return storedUser;

      // Latest user contains some settings, such as mobile and
      // outgoing number.
      var user = storedUser?.copyFrom(latestUser) ?? latestUser;

      user = user.copyWith(
        settings: Settings.defaults.copyFrom(user.settings),
        permissions: storedUser?.permissions,
        client: storedUser?.client,
        voip: () => storedUser?.voip,
      );

      final isFirstTime = storedUser == null;

      // If we're retrieving the user for the first time (logging in),
      // we store the user already, so that the AuthorizationInterceptor
      // can use it.
      if (storedUser == null) {
        _storageRepository.user = user;
      }

      final previous = user;

      user = await tasksToPerform
          .performInParallel(user)
          .then((userMutators) => userMutators.mutateInSequence(user));

      assertAllSettingsHaveValue(user);

      _storageRepository.user = user;

      _eventBus.broadcast(
        LoggedInUserWasRefreshed(
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

  void assertAllSettingsHaveValue(User user) {
    assert(
      user.settings.isComplete,
      // ignore: prefer_interpolation_to_compose_strings
      'The following settings are missing from the user: ' +
          Settings.possibleKeys
              .difference(user.settings.keys)
              .toList()
              .toString(),
    );
  }
}

extension on List<UserRefreshTask> {
  bool get shouldSkipSynchronization => length <= 2;

  Future<List<UserMutator>> performInParallel(User user) =>
      Future.wait(map((task) => task.performer(user)));
}

extension on List<UserMutator> {
  User mutateInSequence(User user) =>
      fold(user, (user, userMutator) => userMutator(user));
}

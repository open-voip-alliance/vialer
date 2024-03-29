import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:vialer/data/API/authentication/user_logged_in.dart';

import '../../../../data/models/event/event_bus.dart';
import '../../../../data/models/onboarding/login_credentials.dart';
import '../../../../data/models/user/events/logged_in_user_was_refreshed.dart';
import '../../../../data/models/user/refresh/user_refresh_task.dart';
import '../../../../data/models/user/refresh/user_refresh_task_performer.dart';
import '../../../../data/models/user/user.dart';
import '../../../../data/repositories/authentication/authentication_repository.dart';
import '../../../../data/repositories/legacy/storage.dart';
import '../../../../dependency_locator.dart';
import '../../../../presentation/util/loggable.dart';
import '../../../../presentation/util/synchronized_task.dart';
import '../../use_case.dart';

@injectable
class RefreshUser extends UseCase with Loggable {
  final _storageRepository = dependencyLocator<StorageRepository>();
  final _auth = dependencyLocator<AuthRepository>();
  final _eventBus = dependencyLocator<EventBus>();

  Future<User?> call({
    required List<UserRefreshTask> tasksToPerform,
    LoginCredentials? credentials,
    bool synchronized = true,
  }) {
    Future<User?> refreshUser() => _refreshUser(credentials, tasksToPerform);

    return synchronized
        ? SynchronizedTask<User?>.named(editUserTask).run(refreshUser)
        : refreshUser();
  }

  Future<User?> _getUser(LoginCredentials? credentials) async {
    try {
      return _auth.getUserFromCredentials(credentials);
    } on Exception {
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
        appAccount: () => storedUser?.appAccount,
        webphoneAccountId: () => storedUser?.webphoneAccountId,
      );

      final isFirstTime = storedUser == null;

      if (isFirstTime) {
        user = await _performFirstTimeTasks(user);
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

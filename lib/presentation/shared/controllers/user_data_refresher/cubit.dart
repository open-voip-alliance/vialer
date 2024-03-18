import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vialer/presentation/util/loggable.dart';

import '../../../../../data/models/user/refresh/user_refresh_task.dart';
import '../../../../../dependency_locator.dart';
import '../../../../../domain/usecases/authentication/get_is_logged_in_somewhere_else.dart';
import '../../../../../domain/usecases/authentication/logout.dart';
import '../../../../../domain/usecases/calling/voip/register_to_middleware.dart';
import '../../../../../domain/usecases/onboarding/is_onboarded.dart';
import '../../../../../domain/usecases/user/get_logged_in_user.dart';
import '../../../../../domain/usecases/user/refresh/refresh_user.dart';
import 'state.dart';

export 'state.dart';

class UserDataRefresherCubit extends Cubit<UserDataRefresherState>
    with Loggable {
  UserDataRefresherCubit() : super(const NotRefreshing());
  final _isOnboarded = IsOnboarded();
  final _getLoggedInUser = GetLoggedInUserUseCase();
  final _refreshUser = RefreshUser();
  final _registerToMiddleware =
      dependencyLocator<RegisterToMiddlewareUseCase>();
  final _isLoggedInSomewhereElse = GetIsLoggedInSomewhereElseUseCase();
  final _logout = Logout();

  final _lastTimeTaskWasRefreshed = <UserRefreshTask, DateTime>{};

  Future<void> refreshIfReady(List<UserRefreshTask> tasksToPerform) async {
    if (!_isOnboarded()) return;

    final oldUser = _getLoggedInUser();

    emit(const Refreshing());

    if (await _isLoggedInSomewhereElse()) {
      logger.info('Logging out because user is logged in somewhere else');
      await _logout();
      logger.info('Logged out');

      emit(const NotRefreshing());

      return;
    }

    tasksToPerform = _onlyReadyTasks(tasksToPerform);

    if (tasksToPerform.isEmpty) {
      emit(const NotRefreshing());
      return;
    }

    tasksToPerform.forEach(
      (task) => _lastTimeTaskWasRefreshed[task] = DateTime.now(),
    );

    final newUser = await _refreshUser(tasksToPerform: tasksToPerform);

    await _registerToMiddleware();

    emit(const NotRefreshing());

    if (oldUser != newUser) {
      logger.info('Refreshed user data with new changes applied');
    }
  }

  /// We're only going to keep tasks that are ready to be refreshed, and the
  /// rest will be removed.
  List<UserRefreshTask> _onlyReadyTasks(List<UserRefreshTask> tasksToPerform) =>
      tasksToPerform
          .where((task) => _lastTimeTaskWasRefreshed[task].isReadyForRefresh)
          .toList();
}

extension on DateTime? {
  /// The minimum duration between which a user refresh can happen.
  static const _minInterval = Duration(seconds: 60);

  bool get isReadyForRefresh =>
      this?.isBefore(DateTime.now().subtract(_minInterval)) ?? true;
}

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../dependency_locator.dart';
import '../../../../../domain/authentication/get_is_logged_in_somewhere_else.dart';
import '../../../../../domain/authentication/logout.dart';
import '../../../../../domain/calling/voip/register_to_voip_middleware.dart';
import '../../../../../domain/legacy/storage.dart';
import '../../../../../domain/onboarding/is_onboarded.dart';
import '../../../../../domain/user/get_logged_in_user.dart';
import '../../../../../domain/user/refresh/refresh_user.dart';
import '../../../../../domain/user/refresh/user_refresh_task.dart';
import '../../../../util/loggable.dart';
import 'state.dart';

export 'state.dart';

class UserDataRefresherCubit extends Cubit<UserDataRefresherState>
    with Loggable {
  final _isOnboarded = IsOnboarded();
  late final _storageRepository = dependencyLocator<StorageRepository>();
  final _getLoggedInUser = GetLoggedInUserUseCase();
  final _refreshUser = RefreshUser();
  final _registerToVoipMiddleware = RegisterToVoipMiddlewareUseCase();
  final _isLoggedInSomewhereElse = GetIsLoggedInSomewhereElseUseCase();
  final _logout = Logout();

  UserDataRefresherCubit() : super(const NotRefreshing());

  Future<void> refreshIfReady() async {
    if (!_isOnboarded()) return;

    final oldUser = _getLoggedInUser();

    emit(const Refreshing());

    if (await _isLoggedInSomewhereElse()) {
      logger.info('Logging out because user is logged in somewhere else');
      await _logout();
      logger.info('Logged out');
      return;
    }

    // If we have refreshed too recently we don't want to do anything.
    if (!_storageRepository.lastUserRefreshedTime.isReadyForRefresh) return;

    _storageRepository.lastUserRefreshedTime = DateTime.now();

    final newUser = await _refreshUser(tasksToPerform: UserRefreshTask.all);

    await _registerToVoipMiddleware();

    emit(const NotRefreshing());

    if (oldUser != newUser) {
      logger.info('Refreshed user data with new changes applied');
    }
  }
}

extension on DateTime? {
  /// The minimum duration between which a user refresh can happen.
  static const _minInterval = Duration(seconds: 15);

  bool get isReadyForRefresh =>
      this?.isBefore(DateTime.now().subtract(_minInterval)) ?? true;
}

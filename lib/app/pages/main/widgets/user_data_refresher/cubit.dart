import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../domain/authentication/get_is_logged_in_somewhere_else.dart';
import '../../../../../domain/authentication/is_onboard.dart';
import '../../../../../domain/authentication/logout.dart';
import '../../../../../domain/calling/voip/register_to_voip_middleware.dart';
import '../../../../../domain/user/get_logged_in_user.dart';
import '../../../../../domain/user/refresh_user.dart';
import '../../../../util/loggable.dart';
import 'state.dart';

export 'state.dart';

class UserDataRefresherCubit extends Cubit<UserDataRefresherState>
    with Loggable {
  final _isOnboard = IsOnboard();
  final _getLoggedInUser = GetLoggedInUserUseCase();
  final _refreshUser = RefreshUser();
  final _registerToVoipMiddleware = RegisterToVoipMiddlewareUseCase();
  final _isLoggedInSomewhereElse = GetIsLoggedInSomewhereElseUseCase();
  final _logout = Logout();

  UserDataRefresherCubit() : super(const NotRefreshing());

  Future<void> refresh() async {
    if (!_isOnboard()) return;

    final oldUser = _getLoggedInUser();

    emit(const Refreshing());

    if (await _isLoggedInSomewhereElse()) {
      logger.info('Logging out because user is logged in somewhere else');
      await _logout();
      logger.info('Logged out');
      return;
    }

    final newUser = await _refreshUser();

    await _registerToVoipMiddleware();

    emit(const NotRefreshing());

    if (oldUser != newUser) {
      logger.info('Refreshed user data with new changes applied');
    }
  }
}

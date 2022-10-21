import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../domain/authentication/get_is_authenticated.dart';
import '../../../../../domain/authentication/get_is_logged_in_somewhere_else.dart';
import '../../../../../domain/authentication/logout.dart';
import '../../../../../domain/calling/voip/get_is_voip_allowed.dart';
import '../../../../../domain/calling/voip/get_server_config.dart';
import '../../../../../domain/calling/voip/get_voip_config.dart';
import '../../../../../domain/calling/voip/register_to_voip_middleware.dart';
import '../../../../../domain/user/get_latest_logged_in_user.dart';
import '../../../../../domain/user/get_logged_in_user.dart';
import '../../../../util/loggable.dart';
import 'state.dart';

export 'state.dart';

class UserDataRefresherCubit extends Cubit<UserDataRefresherState>
    with Loggable {
  final _isAuthenticated = GetIsAuthenticatedUseCase();
  final _getLoggedInUser = GetLoggedInUserUseCase();
  final _getLatestUser = GetLatestLoggedInUserUseCase();
  final _getVoipConfig = GetVoipConfigUseCase();
  final _registerToVoipMiddleware = RegisterToVoipMiddlewareUseCase();
  final _isVoipAllowed = GetIsVoipAllowedUseCase();
  final _isLoggedInSomewhereElse = GetIsLoggedInSomewhereElseUseCase();
  final _logout = LogoutUseCase();
  final _getServerConfig = GetServerConfigUseCase();

  UserDataRefresherCubit() : super(const NotRefreshing());

  Future<void> refresh() async {
    if (!_isAuthenticated()) return;

    final oldUser = _getLoggedInUser();

    emit(const Refreshing());

    if (await _isLoggedInSomewhereElse()) {
      logger.info('Logging out because user is logged in somewhere else');
      await _logout();
      logger.info('Logged out');
      return;
    }

    final newUser = await _getLatestUser();
    await _getServerConfig(latest: true);

    if (await _isVoipAllowed()) {
      await _getVoipConfig(latest: true);
    }

    await _registerToVoipMiddleware();
    emit(const NotRefreshing());

    if (oldUser != newUser) {
      logger.info('Refreshed user data with new changes applied');
    }
  }
}

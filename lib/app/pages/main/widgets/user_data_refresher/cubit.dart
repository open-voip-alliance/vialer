import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../dependency_locator.dart';
import '../../../../../domain/repositories/storage.dart';
import '../../../../../domain/usecases/get_is_logged_in_somewhere_else.dart';
import '../../../../../domain/usecases/get_is_voip_allowed.dart';
import '../../../../../domain/usecases/get_latest_availability.dart';
import '../../../../../domain/usecases/get_latest_voipgrid_permissions.dart';
import '../../../../../domain/usecases/get_server_config.dart';
import '../../../../../domain/usecases/get_user.dart';
import '../../../../../domain/usecases/get_voip_config.dart';
import '../../../../../domain/usecases/logout.dart';
import '../../../../../domain/usecases/register_to_voip_middleware.dart';
import '../../../../util/loggable.dart';
import 'state.dart';

export 'state.dart';

class UserDataRefresherCubit extends Cubit<UserDataRefresherState>
    with Loggable {
  final _getUser = GetUserUseCase();
  final _getLatestAvailability = GetLatestAvailabilityUseCase();
  final _getVoipConfig = GetVoipConfigUseCase();
  final _registerToVoipMiddleware = RegisterToVoipMiddlewareUseCase();
  final _isVoipAllowed = GetIsVoipAllowedUseCase();
  final _isLoggedInSomewhereElse = GetIsLoggedInSomewhereElseUseCase();
  final _logout = LogoutUseCase();
  final _storageRepository = dependencyLocator<StorageRepository>();
  final _getServerConfig = GetServerConfigUseCase();
  final _getLatestVoipgridPermissions = GetLatestVoipgridPermissions();

  UserDataRefresherCubit() : super(const NotRefreshing());

  Future<void> refresh() async {
    final oldUser = _storageRepository.systemUser;

    emit(const Refreshing());

    if (await _isLoggedInSomewhereElse()) {
      logger.info('Logging out because user is logged in somewhere else');
      await _logout();

      emit(const LoggedOut());

      logger.info('Logged out');
      return;
    }

    await _getUser(latest: true);
    await _getLatestAvailability();
    await _getLatestVoipgridPermissions();
    await _getServerConfig(latest: true);

    if (await _isVoipAllowed()) {
      await _getVoipConfig(latest: true);
    }

    await _registerToVoipMiddleware();
    emit(const NotRefreshing());

    final newUser = _storageRepository.systemUser;

    if (oldUser != newUser) {
      logger.info('Refreshed user data with new changes applied');
    }
  }
}

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../domain/usecases/get_latest_availability.dart';
import '../../../../../domain/usecases/get_user.dart';
import '../../../../../domain/usecases/get_voip_config.dart';
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

  UserDataRefresherCubit() : super(const NotRefreshing()) {
    refresh();
  }

  Future<void> refresh() async {
    logger.info('Refreshing latest user data');
    emit(const Refreshing());
    await _getUser(latest: true);
    await _getLatestAvailability();
    await _getVoipConfig(latest: true);
    await _registerToVoipMiddleware();
    emit(const NotRefreshing());
    logger.info('Finished refreshing latest user data');
  }
}

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../domain/usecases/get_latest_app_account.dart';
import '../../../../../domain/usecases/get_latest_availability.dart';
import '../../../../../domain/usecases/get_latest_user.dart';
import '../../../../util/loggable.dart';
import 'state.dart';

export 'state.dart';

class UserDataRefresherCubit extends Cubit<UserDataRefresherState>
    with Loggable {
  final _getLatestUser = GetLatestUserUseCase();
  final _getLatestAvailability = GetLatestAvailabilityUseCase();
  final _getLatestAppAccount = GetLatestAppAccountUseCase();

  UserDataRefresherCubit() : super(const NotRefreshing()) {
    refresh();
  }

  Future<void> refresh() async {
    logger.info('Refreshing latest user data');
    emit(const Refreshing());
    await _getLatestUser();
    await _getLatestAvailability();
    await _getLatestAppAccount();
    emit(const NotRefreshing());
    logger.info('Finished refreshing latest user data');
  }
}

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../domain/usecases/get_latest_availability.dart';
import '../../../../../domain/usecases/get_latest_user.dart';
import '../../../../util/loggable.dart';
import 'state.dart';

export 'state.dart';

class UserRefresherCubit extends Cubit<UserRefresherState> with Loggable {
  final _getLatestUser = GetLatestUserUseCase();
  final _getLatestAvailability = GetLatestAvailabilityUseCase();

  UserRefresherCubit() : super(NotRefreshing()) {
    refresh();
  }

  Future<void> refresh() async {
    logger.info('Refreshing latest user');
    emit(Refreshing());
    await _getLatestUser();
    await _getLatestAvailability();
    emit(NotRefreshing());
    logger.info('Finished refreshing latest user data');
  }
}

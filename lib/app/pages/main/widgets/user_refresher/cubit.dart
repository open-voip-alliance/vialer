import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../domain/usecases/get_latest_user.dart';

import '../../../../util/loggable.dart';

import 'state.dart';
export 'state.dart';

class UserRefresherCubit extends Cubit<UserRefresherState> with Loggable {
  final _getLatestUser = GetLatestUserUseCase();

  UserRefresherCubit() : super(NotRefreshing());

  Future<void> check() async {
    logger.info('Refreshing latest user');
    emit(Refreshing());
    await _getLatestUser();
    emit(NotRefreshing());
    logger.info('Refreshing latest user');
  }
}

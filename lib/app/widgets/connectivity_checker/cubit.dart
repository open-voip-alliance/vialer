import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/connectivity_status.dart';
import '../../../domain/usecases/get_connectivity_status_stream.dart';

import 'state.dart';
export 'state.dart';

class ConnectivityCheckerCubit extends Cubit<ConnectivityState> {
  final _getConnectivityStatusStream = GetConnectivityStatusStreamUseCase();

  StreamSubscription _subscription;

  ConnectivityCheckerCubit() : super(Connected()) {
    _subscription = _getConnectivityStatusStream().listen((status) {
      emit(
        status == ConnectivityStatus.connected ? Connected() : Disconnected(),
      );
    });
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await super.close();
  }
}

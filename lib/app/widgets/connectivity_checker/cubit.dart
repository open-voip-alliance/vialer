import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/user/connectivity/connectivity_type.dart';
import '../../../domain/user/connectivity/get_connectivity_status_stream.dart';
import '../../../domain/user/connectivity/get_current_connectivity_status.dart';
import 'state.dart';

export 'state.dart';

class ConnectivityCheckerCubit extends Cubit<ConnectivityState> {
  final _getConnectivityTypeStream = GetConnectivityTypeStreamUseCase();
  final _getCurrentConnectivityType = GetCurrentConnectivityTypeUseCase();

  late StreamSubscription _subscription;

  ConnectivityCheckerCubit() : super(const Connected()) {
    check();
    _subscription = _getConnectivityTypeStream().listen(
      _emitBasedOnConnectivityType,
    );
  }

  Future<void> check() async =>
      _emitBasedOnConnectivityType(await _getCurrentConnectivityType());

  void _emitBasedOnConnectivityType(ConnectivityType type) => emit(
        type.isConnected ? const Connected() : const Disconnected(),
      );

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await super.close();
  }
}

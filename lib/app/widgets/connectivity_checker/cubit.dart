import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/connectivity_type.dart';
import '../../../domain/usecases/get_connectivity_status_stream.dart';

import 'state.dart';
export 'state.dart';

class ConnectivityCheckerCubit extends Cubit<ConnectivityState> {
  final _getConnectivityTypeStream = GetConnectivityTypeStreamUseCase();

  late StreamSubscription _subscription;

  ConnectivityCheckerCubit() : super(Connected()) {
    _subscription = _getConnectivityTypeStream().listen((status) {
      emit(
        status.isConnected ? Connected() : Disconnected(),
      );
    });
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await super.close();
  }
}

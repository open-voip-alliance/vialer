import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/caller.dart' hide CanCall;

import '../../../../domain/entities/permission_status.dart';
import '../../../../domain/entities/permission.dart';

import '../../../../domain/usecases/get_latest_dialed_number.dart';
import '../../../../domain/usecases/onboarding/request_permission.dart';
import '../../../../domain/usecases/get_permission_status.dart';

import 'state.dart';
export 'state.dart';

class DialerCubit extends Cubit<DialerState> {
  final _getLatestDialedNumber = GetLatestDialedNumber();
  final _getPermissionStatus = GetPermissionStatusUseCase();
  final _requestPermission = RequestPermissionUseCase();

  final CallerCubit _caller;

  DialerCubit(this._caller) : super(CanCall()) {
    _checkCallPermission();
  }

  Future<void> _checkCallPermission() async {
    if (!Platform.isIOS) {
      final status = await _getPermissionStatus(permission: Permission.phone);
      _updateWhetherCanCall(status);
    }
  }

  void _updateWhetherCanCall(PermissionStatus status) {
    if (status == PermissionStatus.granted) {
      emit(CanCall());
    } else {
      emit(
        NoPermission(
          dontAskAgain: status == PermissionStatus.permanentlyDenied,
        ),
      );
    }
  }

  Future<void> requestPermission() async {
    final status = await _requestPermission(permission: Permission.phone);

    _updateWhetherCanCall(status);
  }

  Future<void> startCall(String destination) async {
    // Necessary for auto cast
    final state = this.state;

    if (state is CanCall) {
      if (destination == null || destination.isEmpty) {
        emit(
          CanCall(lastCalledDestination: _getLatestDialedNumber()),
        );
        return;
      }

      await _caller.call(destination);
    }
  }

  void clearLastCalledDestination() {
    emit(CanCall());
  }
}

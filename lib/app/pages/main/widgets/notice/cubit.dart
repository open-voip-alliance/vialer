import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../domain/entities/permission.dart';
import '../../../../../domain/entities/permission_status.dart';
import '../../../../../domain/usecases/get_permission_status.dart';
import '../../../../../domain/usecases/onboarding/request_permission.dart';
import '../../../../../domain/usecases/open_settings.dart';
import '../../../../util/loggable.dart';
import 'state.dart';

export 'state.dart';

class NoticeCubit extends Cubit<NoticeState> with Loggable {
  final _getPermissionStatus = GetPermissionStatusUseCase();
  final _requestPermission = RequestPermissionUseCase();
  final _openAppSettings = OpenSettingsAppUseCase();

  NoticeCubit() : super(const NoNotice()) {
    check();
  }

  Future<void> check([PermissionStatus? microphonePermissionStatus]) async {
    if (state is NoticeDismissed) return;

    microphonePermissionStatus ??= await _getPermissionStatus(
      permission: Permission.microphone,
    );

    if (microphonePermissionStatus != PermissionStatus.granted) {
      emit(const MicrophonePermissionDeniedNotice());
    } else {
      emit(const NoNotice());
    }
  }

  Future<void> openAppSettings() => _openAppSettings();

  Future<void> requestMicrophonePermission() async {
    final micPermissionStatus =
        await _requestPermission(permission: Permission.microphone);

    if (micPermissionStatus != PermissionStatus.granted) {
      await _openAppSettings();
    }

    await check(micPermissionStatus);
  }

  void dismiss() => emit(const NoticeDismissed());
}

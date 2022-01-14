import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../domain/entities/permission.dart';
import '../../../../../domain/entities/permission_status.dart';
import '../../../../../domain/usecases/get_permission_status.dart';
import '../../../../../domain/usecases/onboarding/request_permission.dart';
import '../../../../../domain/usecases/open_settings.dart';
import '../../../../util/loggable.dart';
import '../caller.dart';
import 'state.dart';

export 'state.dart';

class NoticeCubit extends Cubit<NoticeState> with Loggable {
  final _getPermissionStatus = GetPermissionStatusUseCase();
  final _requestPermission = RequestPermissionUseCase();
  final _openAppSettings = OpenSettingsAppUseCase();

  final CallerCubit _caller;

  NoticeCubit(this._caller) : super(const NoNotice()) {
    check();
  }

  Future<void> check({
    PermissionStatus? microphoneStatus,
    PermissionStatus? phoneStatus,
  }) async {
    if (state is NoticeDismissed) return;

    microphoneStatus ??= await _getPermissionStatus(
      permission: Permission.microphone,
    );

    phoneStatus ??= await _getPermissionStatus(
      permission: Permission.phone,
    );

    if (phoneStatus != PermissionStatus.granted &&
        microphoneStatus != PermissionStatus.granted) {
      emit(const PhoneAndMicrophonePermissionDeniedNotice());
    } else if (phoneStatus != PermissionStatus.granted) {
      emit(const PhonePermissionDeniedNotice());
    } else if (microphoneStatus != PermissionStatus.granted) {
      emit(const MicrophonePermissionDeniedNotice());
    } else {
      emit(const NoNotice());
    }
  }

  Future<void> openAppSettings() => _openAppSettings();

  Future<void> requestPermission(List<Permission> permissions) async {
    for (final permission in permissions) {
      assert(
        permission == Permission.phone || permission == Permission.microphone,
      );

      final status = await _requestPermission(permission: permission);

      if (status != PermissionStatus.granted) {
        await _openAppSettings();
      }

      if (permission == Permission.phone &&
          status == PermissionStatus.granted) {
        _caller.initialize();
      }

      await check(
        microphoneStatus: permission == Permission.microphone ? status : null,
        phoneStatus: permission == Permission.phone ? status : null,
      );

      // No need to request more if there's no notice.
      if (state is NoNotice) {
        break;
      }
    }
  }

  void dismiss() => emit(const NoticeDismissed());
}

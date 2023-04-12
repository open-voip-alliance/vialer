import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../dependency_locator.dart';
import '../../../../../domain/business_availability/temporary_redirect/temporary_redirect.dart';
import '../../../../../domain/business_availability/temporary_redirect/temporary_redirect_did_change_event.dart';
import '../../../../../domain/event/event_bus.dart';
import '../../../../../domain/onboarding/request_permission.dart';
import '../../../../../domain/user/get_logged_in_user.dart';
import '../../../../../domain/user/get_permission_status.dart';
import '../../../../../domain/user/permissions/permission.dart';
import '../../../../../domain/user/permissions/permission_status.dart';
import '../../../../../domain/user/settings/open_settings.dart';
import '../../../../util/loggable.dart';
import '../caller.dart';
import 'state.dart';

export 'state.dart';

class NoticeCubit extends Cubit<NoticeState> with Loggable {
  late final _getPermissionStatus = GetPermissionStatusUseCase();
  late final _requestPermission = RequestPermissionUseCase();
  late final _openAppSettings = OpenSettingsAppUseCase();
  late final _getUser = GetLoggedInUserUseCase();
  late final _eventBus = dependencyLocator<EventBusObserver>();

  final CallerCubit _caller;

  NoticeCubit(this._caller) : super(const NoNotice()) {
    check();

    _eventBus.on<TemporaryRedirectDidChangeEvent>((event) {
      check(currentRedirect: event.current);
    });
  }

  Future<void> check({
    PermissionStatus? microphoneStatus,
    PermissionStatus? phoneStatus,
    PermissionStatus? bluetoothStatus,
    PermissionStatus? notificationsStatus,
    TemporaryRedirect? currentRedirect,
  }) async {
    if (state is NoticeDismissed) return;

    microphoneStatus ??= await _getPermissionStatus(
      permission: Permission.microphone,
    );

    phoneStatus = Platform.isIOS
        ? PermissionStatus.granted
        : phoneStatus ??= await _getPermissionStatus(
            permission: Permission.phone,
          );

    bluetoothStatus = Platform.isIOS
        ? PermissionStatus.granted
        : bluetoothStatus ??= await _getPermissionStatus(
            permission: Permission.bluetooth,
          );

    notificationsStatus = Platform.isIOS
        ? notificationsStatus ??= await _getPermissionStatus(
            permission: Permission.notifications,
          )
        : PermissionStatus.granted;

    final user = _getUser();

    if (phoneStatus != PermissionStatus.granted &&
        microphoneStatus != PermissionStatus.granted) {
      emit(const PhoneAndMicrophonePermissionDeniedNotice());
    } else if (phoneStatus != PermissionStatus.granted) {
      emit(const PhonePermissionDeniedNotice());
    } else if (microphoneStatus != PermissionStatus.granted) {
      emit(const MicrophonePermissionDeniedNotice());
    } else if (bluetoothStatus != PermissionStatus.granted) {
      emit(const BluetoothConnectPermissionDeniedNotice());
    } else if (notificationsStatus != PermissionStatus.granted) {
      emit(const NotificationsPermissionDeniedNotice());
    } else if (!user.isAllowedVoipCalling) {
      emit(const NoAppAccountNotice());
    } else if (currentRedirect != null) {
      emit(TemporaryRedirectNotice(
        temporaryRedirect: currentRedirect,
        canChangeTemporaryRedirect: user.permissions.canChangeTemporaryRedirect,
      ));
    } else {
      emit(const NoNotice());
    }
  }

  Future<void> openAppSettings() => _openAppSettings();

  Future<void> requestPermission(List<Permission> permissions) async {
    for (final permission in permissions) {
      assert(
        permission == Permission.phone ||
            permission == Permission.microphone ||
            permission == Permission.bluetooth ||
            permission == Permission.notifications,
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
        bluetoothStatus: permission == Permission.bluetooth ? status : null,
        notificationsStatus:
            permission == Permission.notifications ? status : null,
      );

      // No need to request more if there's no notice.
      if (state is NoNotice) {
        break;
      }
    }
  }

  void dismiss() => emit(const NoticeDismissed());
}

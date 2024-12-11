// Ignored because we actually follow the proper practice here, as stated in the
// lint docs.
// ignore_for_file: parameter_assignments

import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vialer/presentation/util/loggable.dart';

import '../../../../../data/models/business_availability/temporary_redirect/temporary_redirect_did_change_event.dart';
import '../../../../../data/models/event/event_bus.dart';
import '../../../../../data/models/user/events/logged_in_user_was_refreshed.dart';
import '../../../../../data/models/user/permissions/permission.dart' as os;
import '../../../../../data/models/user/permissions/permission_status.dart';
import '../../../../../data/repositories/voipgrid/user_permissions.dart';
import '../../../../../dependency_locator.dart';
import '../../../../../domain/usecases/onboarding/request_permission.dart';
import '../../../../../domain/usecases/user/get_logged_in_user.dart';
import '../../../../../domain/usecases/user/get_permission_status.dart';
import '../../../../../domain/usecases/user/settings/open_settings.dart';
import '../../../../../presentation/util/pigeon.dart';
import '../../widgets/caller.dart';
import 'state.dart';

export 'state.dart';

class NoticeCubit extends Cubit<NoticeState> with Loggable {
  NoticeCubit(this._caller) : super(const NoNotice()) {
    unawaited(check());
    _eventBus
      ..on<TemporaryRedirectDidChangeEvent>((_) => unawaited(check()))
      ..on<LoggedInUserWasRefreshed>((_) => unawaited(check()));
  }

  late final _getPermissionStatus = GetPermissionStatusUseCase();
  late final _requestPermission = RequestPermissionUseCase();
  late final _openAppSettings = OpenSettingsAppUseCase();
  late final _getUser = GetLoggedInUserUseCase();
  late final _eventBus = dependencyLocator<EventBusObserver>();
  late final _googlePlayServices = GooglePlayServices();

  final CallerCubit _caller;

  Future<void> check({
    PermissionStatus? microphoneStatus,
    PermissionStatus? phoneStatus,
    PermissionStatus? bluetoothStatus,
    PermissionStatus? notificationsStatus,
    PermissionStatus? ignoreBatteryOptimization,
  }) async {
    if (state is NoticeDismissed) return;

    microphoneStatus ??= await _getPermissionStatus(
      permission: os.Permission.microphone,
    );

    phoneStatus = Platform.isIOS
        ? PermissionStatus.granted
        : phoneStatus ??= await _getPermissionStatus(
            permission: os.Permission.phone,
          );

    bluetoothStatus = Platform.isIOS
        ? PermissionStatus.granted
        : bluetoothStatus ??= await _getPermissionStatus(
            permission: os.Permission.bluetooth,
          );

    notificationsStatus = Platform.isIOS
        ? notificationsStatus ??= await _getPermissionStatus(
            permission: os.Permission.notifications,
          )
        : PermissionStatus.granted;

    ignoreBatteryOptimization = Platform.isIOS
        ? PermissionStatus.granted
        : ignoreBatteryOptimization ??= await _getPermissionStatus(
            permission: os.Permission.ignoreBatteryOptimizations,
          );

    final user = _getUser();

    final googlePlayServicesIsAvailable =
        Platform.isAndroid ? await _googlePlayServices.isAvailable() : true;

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
      emit(
        NoAppAccountNotice(
          hasPermissionToChangeAppAccount: user.hasPermission(
            Permission.canChangeAppAccount,
          ),
        ),
      );
    } else if (user.client.currentTemporaryRedirect != null) {
      emit(
        TemporaryRedirectNotice(
          temporaryRedirect: user.client.currentTemporaryRedirect!,
          canChangeTemporaryRedirect:
              user.hasPermission(Permission.canChangeTemporaryRedirect),
        ),
      );
    } else if (!googlePlayServicesIsAvailable) {
      emit(const NoGooglePlayServices());
    } else if (ignoreBatteryOptimization != PermissionStatus.granted) {
      emit(const IgnoreBatteryOptimizationsPermissionDeniedNotice());
    } else {
      emit(const NoNotice());
    }
  }

  Future<void> openAppSettings() => _openAppSettings();

  Future<void> requestPermission(List<os.Permission> permissions) async {
    for (final permission in permissions) {
      assert(
        permission == os.Permission.phone ||
            permission == os.Permission.microphone ||
            permission == os.Permission.bluetooth ||
            permission == os.Permission.notifications ||
            permission == os.Permission.ignoreBatteryOptimizations,
        'Must be a relevant permission',
      );

      final status = await _requestPermission(permission: permission);

      if (status != PermissionStatus.granted) {
        await _openAppSettings();
      }

      if (permission == os.Permission.phone &&
          status == PermissionStatus.granted) {
        _caller.initialize();
      }

      await check(
        microphoneStatus:
            permission == os.Permission.microphone ? status : null,
        phoneStatus: permission == os.Permission.phone ? status : null,
        bluetoothStatus: permission == os.Permission.bluetooth ? status : null,
        notificationsStatus:
            permission == os.Permission.notifications ? status : null,
        ignoreBatteryOptimization:
            permission == os.Permission.ignoreBatteryOptimizations
                ? status
                : null,
      );

      // No need to request more if there's no notice.
      if (state is NoNotice) {
        break;
      }
    }
  }

  void dismiss() => emit(const NoticeDismissed());
}

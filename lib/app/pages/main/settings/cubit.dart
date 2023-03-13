import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../dependency_locator.dart';
import '../../../../domain/authentication/logout.dart';
import '../../../../domain/calling/voip/perform_echo_cancellation_calibration.dart';
import '../../../../domain/feedback/send_saved_logs_to_remote.dart';
import '../../../../domain/legacy/storage.dart';
import '../../../../domain/onboarding/request_permission.dart';
import '../../../../domain/openings_hours_basic/should_show_opening_hours_basic.dart';
import '../../../../domain/user/connectivity/connectivity_type.dart';
import '../../../../domain/user/connectivity/get_current_connectivity_status.dart';
import '../../../../domain/user/get_build_info.dart';
import '../../../../domain/user/get_logged_in_user.dart';
import '../../../../domain/user/get_permission_status.dart';
import '../../../../domain/user/permissions/permission.dart';
import '../../../../domain/user/permissions/permission_status.dart';
import '../../../../domain/user/refresh_user.dart';
import '../../../../domain/user/settings/call_setting.dart';
import '../../../../domain/user/settings/change_settings.dart';
import '../../../../domain/user/settings/settings.dart';
import '../../../util/loggable.dart';
import '../widgets/user_data_refresher/cubit.dart';
import 'state.dart';

export 'state.dart';

class SettingsCubit extends Cubit<SettingsState> with Loggable {
  final _changeSettings = ChangeSettingsUseCase();
  final _getBuildInfo = GetBuildInfoUseCase();
  final _sendSavedLogsToRemote = SendSavedLogsToRemoteUseCase();
  final _getPermissionStatus = GetPermissionStatusUseCase();
  final _requestPermission = RequestPermissionUseCase();
  final _logout = Logout();
  final _performEchoCancellationCalibration =
      PerformEchoCancellationCalibrationUseCase();
  final _getUser = GetLoggedInUserUseCase();
  final _shouldShowOpeningHoursBasic = ShouldShowOpeningHoursBasic();

  final _refreshUser = RefreshUser();
  final _getConnectivity = GetCurrentConnectivityTypeUseCase();

  final _storageRepository = dependencyLocator<StorageRepository>();

  late StreamSubscription _userRefresherSubscription;

  SettingsCubit(
    UserDataRefresherCubit userDataRefresher,
  ) : super(SettingsState(user: GetLoggedInUserUseCase()())) {
    _emitUpdatedState();
    _userRefresherSubscription = userDataRefresher.stream.listen(
      (state) {
        if (state is NotRefreshing) {
          _emitUpdatedState();
        }
      },
    );
  }

  Future<void> _emitUpdatedState({bool? isUpdatingRemote}) async {
    // We don't want to emit any refresh changes while we're in the progress
    // of changing remote settings.
    if (state.isUpdatingRemote && isUpdatingRemote == null) {
      return;
    }
    final user = _getUser();
    emit(
      SettingsState(
        user: user,
        buildInfo: await _getBuildInfo(),
        hasIgnoreBatteryOptimizationsPermission: await _getPermissionStatus(
          permission: Permission.ignoreBatteryOptimizations,
        ).then(
          (status) => status == PermissionStatus.granted,
        ),
        userNumber: _storageRepository.userNumber,
        availableDestinations: _storageRepository.availableDestinations,
        isUpdatingRemote: isUpdatingRemote ?? state.isUpdatingRemote,
      ),
    );
  }

  static const _remoteSettings = [
    CallSetting.destination,
    CallSetting.mobileNumber,
    CallSetting.outgoingNumber,
    CallSetting.useMobileNumberAsFallback,
  ];

  /// Returns `true` if [key] refers to a remote setting and we have an
  /// internet connection, or if [key] does not refer to a remote setting.
  Future<bool> canChangeRemoteSetting<T extends Object>(
    SettingKey<T> key,
  ) async =>
      !_remoteSettings.contains(key) ||
      await _getConnectivity().then((c) => c.isConnected);

  Future<void> changeSetting<T extends Object>(
    SettingKey<T> key,
    T value,
  ) async {
    // Immediately emit a copy of the state with the changed setting for extra
    // smoothness.
    final newSettings = Settings({key: value});

    // If this is going to be used for UI purposes we need to be able to work
    // out if the changed settings required a remote sync, but for how it is
    // used currently it's not important.
    emit(state.withChanged(newSettings, isUpdatingRemote: true));
    await _changeSettings(newSettings);
    await _emitUpdatedState(isUpdatingRemote: false);
  }

  Future<void> refreshAvailability() async {
    logger.info('Refreshing availability');
    await _refreshUser(tasksToRun: [UserRefreshTask.availability]);
    await _emitUpdatedState();
  }

  Future<void> requestBatteryPermission() => _requestPermission(
        permission: Permission.ignoreBatteryOptimizations,
      );

  Future<void> sendSavedLogsToRemote() => _sendSavedLogsToRemote();

  Future<void> refresh() => _emitUpdatedState();

  bool get shouldShowOpeningHoursBasic => _shouldShowOpeningHoursBasic();

  Future<void> logout() async {
    logger.info('Logging out');
    await _logout();
    logger.info('Logged out');
  }

  @override
  Future<void> close() async {
    await _userRefresherSubscription.cancel();
    await super.close();
  }

  Future<void> performEchoCancellationCalibration() =>
      _performEchoCancellationCalibration();
}

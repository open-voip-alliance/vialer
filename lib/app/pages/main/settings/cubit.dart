import 'dart:async';

import 'package:dartx/dartx.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../dependency_locator.dart';
import '../../../../domain/authentication/logout.dart';
import '../../../../domain/calling/voip/perform_echo_cancellation_calibration.dart';
import '../../../../domain/event/event_bus.dart';
import '../../../../domain/feedback/send_saved_logs_to_remote.dart';
import '../../../../domain/legacy/storage.dart';
import '../../../../domain/onboarding/request_permission.dart';
import '../../../../domain/openings_hours_basic/should_show_opening_hours_basic.dart';
import '../../../../domain/user/connectivity/connectivity_type.dart';
import '../../../../domain/user/connectivity/get_current_connectivity_status.dart';
import '../../../../domain/user/events/logged_in_user_was_refreshed.dart';
import '../../../../domain/user/get_build_info.dart';
import '../../../../domain/user/get_logged_in_user.dart';
import '../../../../domain/user/get_permission_status.dart';
import '../../../../domain/user/permissions/permission.dart';
import '../../../../domain/user/permissions/permission_status.dart';
import '../../../../domain/user/refresh/refresh_user.dart';
import '../../../../domain/user/refresh/user_refresh_task.dart';
import '../../../../domain/user/settings/call_setting.dart';
import '../../../../domain/user/settings/change_settings.dart';
import '../../../../domain/user/settings/settings.dart';
import '../../../../domain/user/user.dart';
import '../../../../domain/voipgrid/rate_limit_reached_event.dart';
import '../../../util/loggable.dart';
import 'state.dart';

export 'state.dart';

class SettingsCubit extends Cubit<SettingsState> with Loggable {
  SettingsCubit() : super(SettingsState(user: GetLoggedInUserUseCase()())) {
    _emitUpdatedState();
    _eventBus
      ..on<LoggedInUserWasRefreshed>(
        (event) => _emitUpdatedState(user: event.current),
      )
      ..on<RateLimitReachedEvent>((event) {
        _isRateLimited = true;
        _emitUpdatedState();

        Timer(rateLimitDuration, () {
          _isRateLimited = false;
          _emitUpdatedState();
        });
      });
  }

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
  final _eventBus = dependencyLocator<EventBusObserver>();

  final List<_SettingChangeRequest> _changesBeingProcessed = [];

  bool _isRateLimited = false;
  static const rateLimitDuration = Duration(seconds: 60);

  bool get _isUpdatingRemote => _changesBeingProcessed
      .where((request) => !request.hasTimedOut)
      .isNotEmpty;

  void _emitUpdatedState({
    User? user,
  }) {
    unawaited(
      () async {
        // We don't want to emit any refresh changes while we're in the progress
        // of changing remote settings.
        if (_isUpdatingRemote && !_isRateLimited) {
          return;
        }

        user = user ?? _getUser();

        emit(
          SettingsState(
            user: user!,
            buildInfo: await _getBuildInfo(),
            hasIgnoreBatteryOptimizationsPermission: await _getPermissionStatus(
              permission: Permission.ignoreBatteryOptimizations,
            ).then(
              (status) => status == PermissionStatus.granted,
            ),
            userNumber: _storageRepository.userNumber,
            availableDestinations: _storageRepository.availableDestinations,
            isApplyingChanges: _isUpdatingRemote,
            isRateLimited: _isRateLimited,
            recentOutgoingNumbers: _storageRepository.recentOutgoingNumbers,
          ),
        );
      }(),
    );
  }

  static const _remoteSettings = [
    CallSetting.dnd,
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
      (key is CallSetting<T> && !_remoteSettings.contains(key)) ||
      await _getConnectivity().then((c) => c.isConnected);

  /// Checks if any of the settings in the current request can be changed by
  /// calling [canChangeRemoteSetting] on each one.
  Future<bool> canChangeRemoteSettings(Iterable<SettingKey> keys) =>
      Future.wait(keys.map((key) async => canChangeRemoteSetting(key)))
          .then((value) => value.all((canChange) => canChange));

  Future<void> changeSetting<T extends Object>(
    SettingKey<T> key,
    T value,
  ) =>
      changeSettings({key: value});

  Future<void> changeSettings(Map<SettingKey, Object> settings) async {
    // Immediately emit a copy of the state with the changed setting for extra
    // smoothness.
    final newSettings = Settings(settings);

    // We're going to track any requests to update remote and then make sure
    // we don't update the settings page while that's happening. This also
    // allows us to prevent input until changes have finished.
    final changeRequest = _SettingChangeRequest();
    _changesBeingProcessed.add(changeRequest);
    emit(state.withChanged(newSettings, isApplyingChanges: true));
    await _changeSettings(newSettings);
    _changesBeingProcessed.remove(changeRequest);
    _emitUpdatedState();
  }

  Future<void> refreshAvailability() async {
    logger.info('Refreshing availability');
    await _refreshUser(tasksToPerform: [UserRefreshTask.userDestination]);
    _emitUpdatedState();
  }

  void requestBatteryPermission() => unawaited(
        _requestPermission(
          permission: Permission.ignoreBatteryOptimizations,
        ),
      );

  Future<void> sendSavedLogsToRemote() => _sendSavedLogsToRemote();

  void refresh() => _emitUpdatedState();

  bool get shouldShowOpeningHoursBasic => _shouldShowOpeningHoursBasic();

  Future<void> logout() async {
    logger.info('Logging out');
    await _logout();
    logger.info('Logged out');
  }

  Future<void> performEchoCancellationCalibration() =>
      _performEchoCancellationCalibration();
}

class _SettingChangeRequest {
  final DateTime time = DateTime.now();

  /// An arbitrary time before we determine that our setting change request
  /// has timed out. Note that this does not indicate a timeout of the HTTP
  /// request which will still count as completed.
  bool get hasTimedOut =>
      time.isBefore(DateTime.now().subtract(const Duration(seconds: 15)));
}

import 'dart:async';
import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vialer/data/models/user/connectivity/connectivity_type.dart';
import 'package:vialer/data/models/user/settings/app_setting.dart';
import 'package:vialer/domain/usecases/user/settings/change_setting.dart';
import 'package:vialer/presentation/util/loggable.dart';
import 'package:vialer/presentation/util/pigeon.dart';

import '../../../../../data/models/event/event_bus.dart';
import '../../../../../data/models/user/events/logged_in_user_was_refreshed.dart';
import '../../../../../data/models/user/events/user_devices_changed.dart';
import '../../../../../data/models/user/permissions/permission.dart';
import '../../../../../data/models/user/permissions/permission_status.dart';
import '../../../../../data/models/user/refresh/user_refresh_task.dart';
import '../../../../../data/models/user/settings/call_setting.dart';
import '../../../../../data/models/user/settings/settings.dart';
import '../../../../../data/models/user/user.dart';
import '../../../../../data/models/voipgrid/rate_limit_reached_event.dart';
import '../../../../../data/repositories/legacy/storage.dart';
import '../../../../../dependency_locator.dart';
import '../../../../../domain/usecases/authentication/logout.dart';
import '../../../../../domain/usecases/calling/voip/perform_echo_cancellation_calibration.dart';
import '../../../../../domain/usecases/feedback/send_saved_logs_to_remote.dart';
import '../../../../../domain/usecases/onboarding/request_permission.dart';
import '../../../../../domain/usecases/opening_hours_basic/should_show_opening_hours_basic.dart';
import '../../../../../domain/usecases/user/connectivity/get_current_connectivity_status.dart';
import '../../../../../domain/usecases/user/get_build_info.dart';
import '../../../../../domain/usecases/user/get_logged_in_user.dart';
import '../../../../../domain/usecases/user/get_permission_status.dart';
import '../../../../../domain/usecases/user/get_stored_user.dart';
import '../../../../../domain/usecases/user/refresh/refresh_user.dart';
import 'state.dart';

export 'state.dart';

class SettingsCubit extends Cubit<SettingsState> with Loggable {
  SettingsCubit() : super(SettingsState(user: GetLoggedInUserUseCase()())) {
    _emitUpdatedState();
    _eventBus
      ..on<LoggedInUserWasRefreshed>(
        (event) => _emitUpdatedState(user: event.current),
      )
      ..on<UserDevicesChanged>((_) => _emitUpdatedState())
      ..on<RateLimitReachedEvent>((event) {
        _isRateLimited = true;
        _emitUpdatedState();

        Timer(rateLimitDuration, () {
          _isRateLimited = false;
          _emitUpdatedState();
        });
      });
  }

  final _getBuildInfo = GetBuildInfoUseCase();
  final _sendSavedLogsToRemote = SendSavedLogsToRemoteUseCase();
  final _getPermissionStatus = GetPermissionStatusUseCase();
  final _requestPermission = RequestPermissionUseCase();
  final _logout = Logout();
  final _performEchoCancellationCalibration =
      PerformEchoCancellationCalibrationUseCase();
  final _getUser = GetStoredUserUseCase();
  final _shouldShowOpeningHoursBasic = ShouldShowOpeningHoursBasic();

  final _refreshUser = RefreshUser();
  final _getConnectivity = GetCurrentConnectivityTypeUseCase();
  late final _sharedContacts = SharedContacts();

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
        user = user ?? _getUser();

        // We don't want to emit any refresh changes while we're in the progress
        // of changing remote settings or the user isn't logged in (anymore).
        if ((_isUpdatingRemote && !_isRateLimited) || user == null) {
          return;
        }

        emit(
          SettingsState(
            user: user!,
            buildInfo: await _getBuildInfo(),
            hasIgnoreBatteryOptimizationsPermission: await _getPermissionStatus(
              permission: Permission.ignoreBatteryOptimizations,
            ).then(
              (status) => status == PermissionStatus.granted,
            ),
            isCallDirectoryExtensionEnabled: Platform.isIOS
                ? await _sharedContacts.isCallDirectoryExtensionEnabled()
                : false,
            availableDestinations: _storageRepository.availableDestinations,
            isApplyingChanges: _isUpdatingRemote,
            isRateLimited: _isRateLimited,
            recentOutgoingNumbers: _storageRepository.recentOutgoingNumbers,
            hasUnreadFeatureAnnouncements:
                user!.settings.get(AppSetting.hasUnreadFeatureAnnouncements),
          ),
        );
      }(),
    );
  }

  static const _remoteSettings = [
    CallSetting.availabilityStatus,
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

  Future<SettingChangeResult> changeSetting<T extends Object>(
    SettingKey<T> key,
    T value,
  ) =>
      changeSettings({key: value}).then((results) => results.first);

  Future<List<SettingChangeResult>> changeSettings(Settings settings) async {
    // We're going to track any requests to update remote and then make sure
    // we don't update the settings page while that's happening. This also
    // allows us to prevent input until changes have finished.
    final changeRequest = _SettingChangeRequest();
    _changesBeingProcessed.add(changeRequest);
    emit(
      state.withChanged(GetLoggedInUserUseCase()(), isApplyingChanges: true),
    );
    final results = <SettingChangeResult>[];

    for (final entry in settings.entries) {
      results.add(
        await ChangeSettingUseCase()(
          entry.key,
          entry.value,
          force: true,
        ),
      );
    }
    _changesBeingProcessed.remove(changeRequest);
    _emitUpdatedState();
    return results;
  }

  Future<void> refreshAvailability() async {
    logger.info('Refreshing availability');
    await _refreshUser(tasksToPerform: [UserRefreshTask.userDetails]);
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

  Future<void> directUserToConfigureCallDirectoryExtension() =>
      _sharedContacts.directUserToConfigureCallDirectoryExtension();
}

class _SettingChangeRequest {
  final DateTime time = DateTime.now();

  /// An arbitrary time before we determine that our setting change request
  /// has timed out. Note that this does not indicate a timeout of the HTTP
  /// request which will still count as completed.
  bool get hasTimedOut =>
      time.isBefore(DateTime.now().subtract(const Duration(seconds: 15)));
}

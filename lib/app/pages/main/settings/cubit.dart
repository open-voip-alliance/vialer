import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/entities/permission.dart';
import '../../../../domain/entities/permission_status.dart';
import '../../../../domain/entities/settings/settings.dart';
import '../../../../domain/usecases/get_build_info.dart';
import '../../../../domain/usecases/get_is_voip_allowed.dart';
import '../../../../domain/usecases/get_latest_logged_in_user.dart';
import '../../../../domain/usecases/get_logged_in_user.dart';
import '../../../../domain/usecases/get_permission_status.dart';
import '../../../../domain/usecases/logout.dart';
import '../../../../domain/usecases/onboarding/request_permission.dart';
import '../../../../domain/usecases/perform_echo_cancellation_calibration.dart';
import '../../../../domain/usecases/send_saved_logs_to_remote.dart';
import '../../../../domain/usecases/settings/change_settings.dart';
import '../../../util/loggable.dart';
import '../widgets/user_data_refresher/cubit.dart';
import 'state.dart';

export 'state.dart';

class SettingsCubit extends Cubit<SettingsState> with Loggable {
  final _changeSettings = ChangeSettingsUseCase();
  final _getBuildInfo = GetBuildInfoUseCase();
  final _sendSavedLogsToRemote = SendSavedLogsToRemoteUseCase();
  final _getIsVoipAllowed = GetIsVoipAllowedUseCase();
  final _getPermissionStatus = GetPermissionStatusUseCase();
  final _requestPermission = RequestPermissionUseCase();
  final _logout = LogoutUseCase();
  final _performEchoCancellationCalibration =
      PerformEchoCancellationCalibrationUseCase();
  final _getUser = GetLoggedInUserUseCase();
  final _getLatestUser = GetLatestLoggedInUserUseCase();

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

  Future<void> _emitUpdatedState() async {
    emit(
      SettingsState(
        user: _getUser(),
        buildInfo: await _getBuildInfo(),
        isVoipAllowed: await _getIsVoipAllowed(),
        hasIgnoreBatteryOptimizationsPermission: await _getPermissionStatus(
          permission: Permission.ignoreBatteryOptimizations,
        ).then(
          (status) => status == PermissionStatus.granted,
        ),
      ),
    );
  }

  Future<void> changeSetting<T extends Object>(
    SettingKey<T> key,
    T value,
  ) async {
    // Immediately emit a copy of the state with the changed setting for extra
    // smoothness.
    final newSettings = Settings({key: value});

    emit(state.withChanged(newSettings));

    final result = await _changeSettings(newSettings);

    // If the setting didn't change, it means we have to revert our previous
    // state change.
    if (!result.changed.contains(key)) {
      await _emitUpdatedState();
    }
  }

  Future<void> refreshAvailability() async {
    logger.info('Refreshing availability');

    // TODO: Add ability to refresh a user partially?
    await _getLatestUser();
    await _emitUpdatedState();
  }

  Future<void> requestBatteryPermission() => _requestPermission(
        permission: Permission.ignoreBatteryOptimizations,
      );

  Future<void> sendSavedLogsToRemote() => _sendSavedLogsToRemote();

  Future<void> refresh() => _emitUpdatedState();

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

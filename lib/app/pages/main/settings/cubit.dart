import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/entities/setting.dart';
import '../../../../domain/usecases/change_setting.dart';
import '../../../../domain/usecases/get_build_info.dart';
import '../../../../domain/usecases/get_is_voip_allowed.dart';
import '../../../../domain/usecases/get_latest_availability.dart';
import '../../../../domain/usecases/get_settings.dart';
import '../../../../domain/usecases/logout.dart';
import '../../../../domain/usecases/send_saved_logs_to_remote.dart';
import '../../../util/loggable.dart';
import '../widgets/user_data_refresher/cubit.dart';
import 'state.dart';\

export 'state.dart';

class SettingsCubit extends Cubit<SettingsState> with Loggable {
  final _getSettings = GetSettingsUseCase();
  final _changeSetting = ChangeSettingUseCase();
  final _getBuildInfo = GetBuildInfoUseCase();
  final _getLatestAvailability = GetLatestAvailabilityUseCase();
  final _sendSavedLogsToRemote = SendSavedLogsToRemoteUseCase();
  final _getIsVoipAllowed = GetIsVoipAllowed();
  final _logout = LogoutUseCase();

  late StreamSubscription _userRefresherSubscription;

  SettingsCubit(
    UserDataRefresherCubit userDataRefresher,
  ) : super(SettingsState()) {
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
    emit(SettingsState(
        settings: await _getSettings(),
        buildInfo: await _getBuildInfo(),
        isVoipAllowed: await _getIsVoipAllowed(),
      ),
    );
  }

  Future<void> changeSetting(Setting setting) async {
    logger.info('Set ${setting.runtimeType} to ${setting.value}');

    // Immediately emit a copy of the state with the changed setting for extra
    // smoothness.
    emit(state.withChanged(setting));

    await _changeSetting(setting: setting);

    // TODO (possibly): Use something like the built_value package for lists
    // in states, so that if there's no difference in the setting after it has
    // been changed for real, we don't emit the basically same state again.
    await _emitUpdatedState();
  }

  Future<void> refreshAvailability() async {
    logger.info('Refreshing availability');

    await _getLatestAvailability();
    await _emitUpdatedState();
  }

  Future<void> sendSavedLogsToRemote() => _sendSavedLogsToRemote();

  Future<void> logout() async {
    logger.info('Logging out');
    await _logout();

    emit(LoggedOut());

    logger.info('Logged out');
  }

  @override
  Future<void> close() async {
    await _userRefresherSubscription.cancel();
    await super.close();
  }
}

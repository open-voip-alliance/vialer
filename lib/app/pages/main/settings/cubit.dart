import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/entities/setting.dart';

import '../../../../domain/usecases/get_build_info.dart';
import '../../../../domain/usecases/get_settings.dart';
import '../../../../domain/usecases/change_setting.dart';

import '../../../../domain/usecases/logout.dart';

import '../../../util/loggable.dart';

import 'state.dart';
export 'state.dart';

class SettingsCubit extends Cubit<SettingsState> with Loggable {
  final _getSettings = GetSettingsUseCase();
  final _changeSetting = ChangeSettingUseCase();
  final _getBuildInfo = GetBuildInfoUseCase();
  final _logout = LogoutUseCase();

  SettingsCubit() : super(SettingsState()) {
    _emitUpdatedState();
  }

  Future<void> _emitUpdatedState() async {
    emit(
      SettingsState(
        settings: await _getSettings(),
        buildInfo: await _getBuildInfo(),
      ),
    );
  }

  void changeSetting(Setting setting) {
    logger.info('Set ${setting.runtimeType} to ${setting.value}');
    _changeSetting(setting: setting);
    _emitUpdatedState();
  }

  Future<void> logout() async {
    logger.info('Logging out');
    await _logout();

    emit(LoggedOut());

    logger.info('Logged out');
  }
}

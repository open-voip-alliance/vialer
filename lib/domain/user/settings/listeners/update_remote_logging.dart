import 'dart:async';

import '../../../../app/util/loggable.dart';
import '../../../user/user.dart';
import '../app_setting.dart';
import 'setting_change_listener.dart';

class UpdateRemoteLoggingListener extends SettingChangeListener<bool>
    with Loggable {
  //final _enableRemoteLogging = EnableRemoteLoggingUseCase();

  @override
  final key = AppSetting.remoteLogging;

  @override
  FutureOr<SettingChangeListenResult> beforeStore(
    User user,
    bool enabled,
  ) async {
    if (enabled) {
      //TODO await _enableRemoteLogging();
    } else {
      //await _disableRemoteLogging();
    }

    return successResult;
  }
}

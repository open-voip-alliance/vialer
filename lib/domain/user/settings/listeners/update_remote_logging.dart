import 'dart:async';

import '../../../../app/util/loggable.dart';
import '../../../remote_logging/disable_remote_logging.dart';
import '../../../remote_logging/enable_remote_logging.dart';
import '../../../user/user.dart';
import '../app_setting.dart';
import 'setting_change_listener.dart';

class UpdateRemoteLoggingListener extends SettingChangeListener<bool>
    with Loggable {
  final _enableRemoteLogging = EnableRemoteLoggingUseCase();
  final _disableRemoteLogging = DisableRemoteLoggingUseCase();

  @override
  final key = AppSetting.remoteLogging;

  @override
  FutureOr<SettingChangeListenResult> preStore(
    User user,
    bool enabled,
  ) async {
    if (enabled) {
      await _enableRemoteLogging();
    } else {
      await _disableRemoteLogging();
    }

    return successResult;
  }
}

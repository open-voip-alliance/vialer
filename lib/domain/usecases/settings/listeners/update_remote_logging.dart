import 'dart:async';

import '../../../../app/util/loggable.dart';
import '../../../entities/settings/app_setting.dart';
import '../../../entities/user.dart';
import '../../disable_remote_logging.dart';
import '../../enable_remote_logging.dart';
import 'setting_change_listener.dart';

class UpdateRemoteLoggingListener extends SettingChangeListener<bool>
    with Loggable {
  final _enableRemoteLogging = EnableRemoteLoggingUseCase();
  final _disableRemoteLogging = DisableRemoteLoggingUseCase();

  @override
  final key = AppSetting.remoteLogging;

  @override
  FutureOr<SettingChangeListenResult> beforeStore(
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

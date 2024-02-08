import 'dart:async';

import '../../../../../domain/usecases/remote_logging/disable_remote_logging.dart';
import '../../../../../domain/usecases/remote_logging/enable_remote_logging.dart';
import '../../../../../presentation/util/loggable.dart';
import '../../user.dart';
import '../app_setting.dart';
import 'setting_change_listener.dart';

class UpdateRemoteLoggingListener extends SettingChangeListener<bool>
    with Loggable {
  final _enableRemoteLogging = EnableRemoteLoggingUseCase();
  final _disableRemoteLogging = DisableRemoteLoggingUseCase();

  @override
  final key = AppSetting.remoteLogging;

  @override
  FutureOr<SettingChangeListenResult> applySettingsSideEffects(
    User user,
    bool value,
  ) async {
    if (value) {
      await _enableRemoteLogging();
    } else {
      await _disableRemoteLogging();
    }

    return successResult;
  }
}

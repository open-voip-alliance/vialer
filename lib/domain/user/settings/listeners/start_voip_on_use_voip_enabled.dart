import 'dart:async';

import '../../../../app/util/loggable.dart';
import '../../../calling/voip/register_to_middleware.dart';
import '../../../calling/voip/start_voip.dart';
import '../../../user/user.dart';
import '../call_setting.dart';
import 'setting_change_listener.dart';

class StartVoipOnUseVoipEnabledListener extends SettingChangeListener<bool>
    with Loggable {
  final _registerToVoipMiddleware = RegisterToMiddlewareUseCase();
  final _startVoip = StartVoipUseCase();

  @override
  final key = CallSetting.useVoip;

  @override
  FutureOr<SettingChangeListenResult> applySettingsSideEffects(
    User user,
    bool value,
  ) async {
    if (!value) return successResult;

    try {
      await _registerToVoipMiddleware();
      await _startVoip();
      // ignore: avoid_catching_errors
    } on Error {
      return failedResult;
    }

    return successResult;
  }
}

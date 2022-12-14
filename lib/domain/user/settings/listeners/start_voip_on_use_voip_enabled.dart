import 'dart:async';

import '../../../../app/util/loggable.dart';
import '../../../calling/voip/register_to_voip_middleware.dart';
import '../../../calling/voip/start_voip.dart';
import '../../../user/user.dart';
import '../call_setting.dart';
import 'setting_change_listener.dart';

class StartVoipOnUseVoipEnabledListener extends SettingChangeListener<bool>
    with Loggable {
  final _registerToVoipMiddleware = RegisterToVoipMiddlewareUseCase();
  final _startVoip = StartVoipUseCase();

  @override
  final key = CallSetting.useVoip;

  @override
  FutureOr<SettingChangeListenResult> afterStore(
    User user,
    bool useVoip,
  ) async {
    if (!useVoip) return successResult;

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

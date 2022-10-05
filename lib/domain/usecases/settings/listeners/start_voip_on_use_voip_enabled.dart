import 'dart:async';

import '../../../../app/util/loggable.dart';
import '../../../entities/settings/call_setting.dart';
import '../../../entities/user.dart';
import '../../register_to_voip_middleware.dart';
import '../../start_voip.dart';
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

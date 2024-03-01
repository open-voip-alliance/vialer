import 'dart:async';

import '../../../../../dependency_locator.dart';
import '../../../../../domain/usecases/calling/voip/register_to_middleware.dart';
import '../../../../../domain/usecases/calling/voip/start_voip.dart';
import '../../../../../presentation/util/loggable.dart';
import '../../user.dart';
import '../call_setting.dart';
import 'setting_change_listener.dart';

class StartVoipOnUseVoipEnabledListener extends SettingChangeListener<bool>
    with Loggable {
  final _registerToMiddleware =
      dependencyLocator<RegisterToMiddlewareUseCase>();

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
      await _registerToMiddleware();
      await _startVoip();
      // ignore: avoid_catching_errors
    } on Error {
      return failedResult;
    }

    return successResult;
  }
}

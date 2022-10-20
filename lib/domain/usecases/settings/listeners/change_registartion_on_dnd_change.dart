import 'dart:async';

import '../../../../app/util/loggable.dart';
import '../../../entities/settings/call_setting.dart';
import '../../../entities/user.dart';
import '../../register_to_voip_middleware.dart';
import '../../unregister_to_voip_middleware.dart';
import 'setting_change_listener.dart';

class ChangeRegistrationOnDndChange extends SettingChangeListener<bool>
    with Loggable {
  final _registerToVoipMiddleware = RegisterToVoipMiddlewareUseCase();
  final _unregisterToVoipMiddleware = UnregisterToVoipMiddlewareUseCase();

  @override
  final key = CallSetting.dnd;

  @override
  FutureOr<SettingChangeListenResult> afterStore(User user, bool dndEnabled) {
    // This will happen in the background because we do not need to rely
    // on this to have happened when the user changes the setting.
    if (dndEnabled) {
      _unregisterToVoipMiddleware();
    } else {
      _registerToVoipMiddleware();
    }

    return successResult;
  }
}

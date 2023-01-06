import 'dart:async';

import '../../../../app/util/loggable.dart';
import '../../../calling/voip/register_to_voip_middleware.dart';
import '../../../user/user.dart';
import '../call_setting.dart';
import 'setting_change_listener.dart';

class ChangeRegistrationOnDndChange extends SettingChangeListener<bool>
    with Loggable {
  final _registerToVoipMiddleware = RegisterToVoipMiddlewareUseCase();

  @override
  final key = CallSetting.dnd;

  @override
  FutureOr<SettingChangeListenResult> afterStore(User user, bool dndEnabled) {
    // This will happen in the background because we do not need to rely
    // on this to have happened when the user changes the setting.
    //
    // The correct value for DND will be automatically submitted when refreshing
    // our registration.
    _registerToVoipMiddleware();

    return successResult;
  }
}

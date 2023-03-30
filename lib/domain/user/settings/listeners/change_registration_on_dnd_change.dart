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
  FutureOr<SettingChangeListenResult> postStore(
    User user,
    bool dndEnabled,
  ) async {
    // The correct value for DND will be automatically submitted when refreshing
    // our registration.
    await _registerToVoipMiddleware();

    return successResult;
  }
}

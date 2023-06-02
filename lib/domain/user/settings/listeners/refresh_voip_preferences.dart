import 'dart:async';

import '../../../../app/util/loggable.dart';
import '../../../../dependency_locator.dart';
import '../../../calling/voip/voip.dart';
import '../../../user/user.dart';
import '../app_setting.dart';
import '../call_setting.dart';
import '../settings.dart';
import 'setting_change_listener.dart';

class RefreshVoipPreferences extends SettingChangeListener<bool> with Loggable {
  final _voipRepository = dependencyLocator<VoipRepository>();

  @override
  final SettingKey<bool> key = CallSetting.usePhoneRingtone;

  @override
  final otherKeys = const [AppSetting.showCallsInNativeRecents];

  @override
  FutureOr<SettingChangeListenResult> postStore(
    User user,
    bool value,
  ) async {
    await _voipRepository.refreshPreferences(user);
    return successResult;
  }
}

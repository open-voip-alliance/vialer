import 'dart:async';

import '../../../../../dependency_locator.dart';
import '../../../../../presentation/util/loggable.dart';
import '../../../../repositories/calling/voip/voip.dart';
import '../../user.dart';
import '../app_setting.dart';
import '../call_setting.dart';
import '../settings.dart';
import 'setting_change_listener.dart';

class RefreshVoipPreferences extends SettingChangeListener<bool> with Loggable {
  final _voipRepository = dependencyLocator<VoipRepository>();

  @override
  final SettingKey<bool> key = CallSetting.usePhoneRingtone;

  @override
  final otherKeys = const [
    AppSetting.showCallsInNativeRecents,
    AppSetting.enableAdvancedVoipLogging,
  ];

  @override
  FutureOr<SettingChangeListenResult> applySettingsSideEffects(
    User user,
    bool value,
  ) async {
    await _voipRepository.refreshPreferences(user);
    return successResult;
  }
}

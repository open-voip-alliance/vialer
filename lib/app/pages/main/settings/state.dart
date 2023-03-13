import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../domain/calling/voip/destination.dart';
import '../../../../domain/user/info/build_info.dart';
import '../../../../domain/user/settings/app_setting.dart';
import '../../../../domain/user/settings/call_setting.dart';
import '../../../../domain/user/settings/settings.dart';
import '../../../../domain/user/user.dart';

part 'state.freezed.dart';

@freezed
class SettingsState with _$SettingsState {
  const SettingsState._();

  const factory SettingsState({
    required User user,
    BuildInfo? buildInfo,
    @Default(true) bool isVoipAllowed,
    @Default(false) bool hasIgnoreBatteryOptimizationsPermission,
    @Default(false) bool hasTemporaryRedirect,
    int? userNumber,
    @Default([Destination.notAvailable()])
        List<Destination> availableDestinations,
    @Default(false) bool isUpdatingRemote,
    @Default([]) List<SettingKey> failedSettingChanges,
  }) = _SettingsState;

  bool get showTroubleshooting =>
      user.settings.get(AppSetting.showTroubleshooting);
  bool get showDnd => isVoipAllowed && user.settings.get(CallSetting.useVoip);

  bool didFail(SettingKey key) => failedSettingChanges.contains(key);

  SettingsState withChanged(
    Settings settings, {
    bool isUpdatingRemote = false,
  }) =>
      copyWith(
        user: user.copyWith(settings: user.settings.copyFrom(settings)),
        isUpdatingRemote: isUpdatingRemote,
        failedSettingChanges: [],
      );
}

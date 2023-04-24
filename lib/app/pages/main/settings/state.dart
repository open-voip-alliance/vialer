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
    @Default(false) bool hasIgnoreBatteryOptimizationsPermission,
    @Default(false) bool hasTemporaryRedirect,
    int? userNumber,
    @Default([Destination.notAvailable()])
        List<Destination> availableDestinations,

    /// If we are currently in the process of applying changes, this is usually
    /// when updating a remote setting, so waiting for an API response.
    @Default(false) bool isApplyingChanges,
    @Default(false) bool isRateLimited,
  }) = _SettingsState;

  bool get showTroubleshooting =>
      user.settings.get(AppSetting.showTroubleshooting);
  bool get showDnd =>
      user.isAllowedVoipCalling && user.settings.get(CallSetting.useVoip);
  bool get shouldAllowRemoteSettings => !isApplyingChanges && !isRateLimited;

  SettingsState withChanged(
    Settings settings, {
    bool isApplyingChanges = false,
  }) =>
      copyWith(
        user: user.copyWith(settings: user.settings.copyFrom(settings)),
        isApplyingChanges: isApplyingChanges,
      );
}

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../domain/calling/outgoing_number/outgoing_number.dart';
import '../../../../domain/calling/voip/destination.dart';
import '../../../../domain/user/info/build_info.dart';
import '../../../../domain/user/settings/app_setting.dart';
import '../../../../domain/user/settings/call_setting.dart';
import '../../../../domain/user/user.dart';

part 'state.freezed.dart';

@freezed
class SettingsState with _$SettingsState {
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
    @Default(Iterable<OutgoingNumber>.empty())
    Iterable<OutgoingNumber> recentOutgoingNumbers,
    @Default(false) bool hasUnreadFeatureAnnouncements,
  }) = _SettingsState;

  const SettingsState._();

  bool get showTroubleshooting =>
      user.settings.get(AppSetting.showTroubleshooting);

  bool get showDnd =>
      user.isAllowedVoipCalling && user.settings.get(CallSetting.useVoip);

  bool get shouldAllowRemoteSettings => !isApplyingChanges && !isRateLimited;

  SettingsState withChanged(
    User user, {
    bool isApplyingChanges = false,
  }) =>
      copyWith(
        user: user,
        isApplyingChanges: isApplyingChanges,
      );
}

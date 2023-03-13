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
    @Default(false) bool isUpdatingRemote,
  }) = _SettingsState;

  bool get showTroubleshooting =>
      user.settings.get(AppSetting.showTroubleshooting);
  bool get showDnd => isVoipAllowed && user.settings.get(CallSetting.useVoip);

  // TODO: Remove this when merged with setting revamp.
  bool get isVoipAllowed => true;

  SettingsState withChanged(
    Settings settings, {
    bool isUpdatingRemote = false,
  }) =>
      copyWith(
        user: user.copyWith(settings: user.settings.copyFrom(settings)),
        isUpdatingRemote: isUpdatingRemote,
      );
}

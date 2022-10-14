import 'package:equatable/equatable.dart';

import '../../../../domain/user/info/build_info.dart';
import '../../../../domain/user/settings/app_setting.dart';
import '../../../../domain/user/settings/call_setting.dart';
import '../../../../domain/user/settings/settings.dart';
import '../../../../domain/user/user.dart';

class SettingsState extends Equatable {
  final User user;
  final BuildInfo? buildInfo;
  final bool isVoipAllowed;
  final bool showTroubleshooting;
  final bool showDnd;
  final bool hasIgnoreBatteryOptimizationsPermission;

  SettingsState({
    this.buildInfo,
    this.isVoipAllowed = true,
    required this.user,
    this.hasIgnoreBatteryOptimizationsPermission = false,
  })  : showTroubleshooting = user.settings.get(AppSetting.showTroubleshooting),
        showDnd = isVoipAllowed && (user.settings.get(CallSetting.useVoip));

  SettingsState withChanged(Settings settings) {
    return SettingsState(
      user: user.copyWith(settings: user.settings.copyFrom(settings)),
      buildInfo: buildInfo,
      isVoipAllowed: isVoipAllowed,
      hasIgnoreBatteryOptimizationsPermission:
          hasIgnoreBatteryOptimizationsPermission,
    );
  }

  @override
  List<Object?> get props => [
        user,
        buildInfo,
        isVoipAllowed,
        showTroubleshooting,
        showDnd,
        hasIgnoreBatteryOptimizationsPermission,
      ];
}

import 'package:equatable/equatable.dart';

import '../../../../domain/entities/build_info.dart';
import '../../../../domain/entities/setting.dart';

class SettingsState extends Equatable {
  final List<Setting> settings;
  final BuildInfo? buildInfo;
  final bool isVoipAllowed;
  final bool showTroubleshooting;
  final bool showAbout;

  bool get isLoading => settings.isEmpty;

  SettingsState({
    this.settings = const [],
    this.buildInfo,
    this.isVoipAllowed = true,
    this.showAbout = false,
  }) : showTroubleshooting =
            settings.getOrNull<ShowTroubleshootingSettingsSetting>()?.value ??
                false;

  SettingsState withChanged(Setting setting) {
    return SettingsState(
      settings: List.from(settings)
        // Remove the current setting with the same type, and
        // add the new one with the updated value.
        ..removeWhere((s) => s.runtimeType == setting.runtimeType)
        ..add(setting),
      buildInfo: buildInfo,
      isVoipAllowed: isVoipAllowed,
      showAbout: showAbout,
    );
  }

  @override
  List<Object?> get props => [
        settings,
        buildInfo,
        isVoipAllowed,
        showTroubleshooting,
        showAbout,
      ];
}

class LoggedOut extends SettingsState {}

import 'package:equatable/equatable.dart';

import '../../../../domain/entities/build_info.dart';
import '../../../../domain/entities/setting.dart';
import '../../../../domain/entities/system_user.dart';
import 'widgets/tile.dart';

class SettingsState extends Equatable {
  final List<Setting> settings;
  final BuildInfo? buildInfo;
  final bool isVoipAllowed;
  final bool showTroubleshooting;
  final bool showDnd;
  final SystemUser? systemUser;

  bool get isLoading => settings.isEmpty;

  UserAvailabilityType? get userAvailabilityType {
    final user = systemUser;

    if (user == null) return null;

    final availability = settings.get<AvailabilitySetting>().value;

    return availability != null ? user.availabilityType(availability) : null;
  }

  SettingsState({
    this.settings = const [],
    this.buildInfo,
    this.isVoipAllowed = true,
    this.systemUser,
  })  : showTroubleshooting =
            settings.getOrNull<ShowTroubleshootingSettingsSetting>()?.value ??
                false,
        showDnd = isVoipAllowed &&
            (settings.getOrNull<UseVoipSetting>()?.value ?? false);

  SettingsState withChanged(Setting setting) {
    return SettingsState(
      settings: List.from(settings)
        // Remove the current setting with the same type, and
        // add the new one with the updated value.
        ..removeWhere((s) => s.runtimeType == setting.runtimeType)
        ..add(setting),
      buildInfo: buildInfo,
      isVoipAllowed: isVoipAllowed,
      systemUser: systemUser,
    );
  }

  @override
  List<Object?> get props => [
        settings,
        buildInfo,
        isVoipAllowed,
        showTroubleshooting,
        showDnd,
      ];
}

class LoggedOut extends SettingsState {}

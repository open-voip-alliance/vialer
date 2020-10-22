import 'package:equatable/equatable.dart';

import '../../../../domain/entities/build_info.dart';
import '../../../../domain/entities/setting.dart';

class SettingsState extends Equatable {
  final List<Setting> settings;
  final BuildInfo buildInfo;

  SettingsState({this.settings = const [], this.buildInfo});

  SettingsState withChanged(Setting setting) {
    return SettingsState(
      settings: List.from(settings)
        // Remove the current setting with the same type, and
        // add the new one with the updated value.
        ..removeWhere((s) => s.runtimeType == setting.runtimeType)
        ..add(setting),
      buildInfo: buildInfo,
    );
  }

  @override
  List<Object> get props => [settings, buildInfo];
}

class LoggedOut extends SettingsState {}

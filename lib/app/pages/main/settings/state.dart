import 'package:equatable/equatable.dart';

import '../../../../domain/entities/build_info.dart';
import '../../../../domain/entities/setting.dart';

class SettingsState extends Equatable {
  final List<Setting> settings;
  final BuildInfo buildInfo;

  SettingsState({this.settings = const [], this.buildInfo});

  @override
  List<Object> get props => [settings, buildInfo];
}

class LoggedOut extends SettingsState {}

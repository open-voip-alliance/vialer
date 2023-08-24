import 'dart:async';

import 'package:vialer/domain/user/settings/change_setting.dart';

import '../../use_case.dart';

import 'settings.dart';

class ChangeSettingsUseCase extends UseCase {
  Future<void> call(
    Map<SettingKey, Object> settings, {
    bool track = true,
  }) async =>
      settings.forEach(
        (key, value) async => ChangeSettingUseCase()(key, value, track: track),
      );
}

import 'dart:async';

import '../../use_case.dart';

import 'force_update_setting.dart';
import 'settings.dart';

/// A convenience for force updating multiple settings, see [ForceUpdateSetting]
/// for more information.
class ForceUpdateSettings extends UseCase {
  Future<void> call(Settings settings) async => settings.forEach(
        (key, value) async => ForceUpdateSetting()(key, value),
      );
}

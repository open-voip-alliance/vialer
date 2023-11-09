import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vialer/domain/calling/voip/destination.dart';

import '../../../dependency_locator.dart';
import '../../use_case.dart';
import '../../user/settings/call_setting.dart';
import '../../user/settings/settings_repository.dart';

/// This runs when the app starts. It migrates the former Destination settings,
/// stored as an object to the new form, just the id.
class ApplyDestinationMigration extends UseCase {
  final settings = dependencyLocator<SettingsRepository>();
  final preferences = dependencyLocator<SharedPreferences>();

  void call() {
    final destination =
        preferences.get(CallSetting.destination.asSharedPreferencesKey());

    if (destination == null ||
        (destination is String && destination.isNumeric())) return;

    try {
      final setting = jsonDecode(destination as String) as Map<String, dynamic>;

      final runtimeType = setting['runtimeType'];
      if (['phoneNumber', 'phoneAccount'].contains(runtimeType)) {
        settings.change(CallSetting.destination, setting['id'] as int);
      } else if (runtimeType == 'unknown') {
        settings.change(
          CallSetting.destination,
          Destination.unknown().identifier,
        );
      } else {
        settings.change(
          CallSetting.destination,
          Destination.notAvailable().identifier,
        );
      }
    } on Exception {
      // As a fallback, set to unknown destination.
      settings.change(
        CallSetting.destination,
        Destination.unknown().identifier,
      );
    }
  }
}

extension on String {
  bool isNumeric() => num.tryParse(this) != null;
}

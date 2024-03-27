import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:vialer/data/models/calling/voip/destination.dart';

import '../../../../data/models/user/settings/call_setting.dart';
import '../../../../data/repositories/user/settings/settings_repository.dart';
import '../../../../dependency_locator.dart';
import '../../use_case.dart';
import '../../../util/numberic_strings.dart';

/// This runs when the app starts. It migrates the former Destination settings,
/// stored as an object to the new form, just the id.
class MigrateDestinationObjectToIdentifier extends UseCase {
  final settings = dependencyLocator<SettingsRepository>();
  final preferences = dependencyLocator<SharedPreferences>();

  void call() {
    final setting =
        preferences.get(CallSetting.destination.asSharedPreferencesKey());

    if (setting == null || (setting is String && setting.isNumeric())) return;

    final destination = Destination.fromJson(
      jsonDecode(setting as String) as Map<String, dynamic>,
    );

    switch (destination) {
      case PhoneNumber():
      case PhoneAccount():
        settings.change(CallSetting.destination, destination.identifier);
        break;
      case Unknown():
        settings.change(
          CallSetting.destination,
          Destination.unknown().identifier,
        );
        break;
      case NotAvailable():
        settings.change(
          CallSetting.destination,
          Destination.notAvailable().identifier,
        );
        break;
    }
  }
}

import 'dart:convert';

import 'package:recase/recase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vialer/dependency_locator.dart';

import '../../use_case.dart';

/// Imports any legacy settings from when settings were stored against the user
/// object in a single json blob.
///
/// This doesn't interact with settings at all, just directly dumps the settings
/// into separate keys.
///
/// This should be removed when almost all users have upgraded from 7.36.0.
class ImportLegacySettings extends UseCase {
  late final _preferences = dependencyLocator<SharedPreferences>();

  Future<void> call() async {
    if (!_preferences.containsKey('system_user')) return;

    final userJson = _preferences.getString('system_user')!;

    if (!userJson.contains('"settings"')) return;

    final legacySettings =
        jsonDecode(userJson)['settings'] as Map<String, dynamic>;

    for (final entry in legacySettings.entries) {
      final key = entry.key;
      final value = entry.value;

      await _preferences.setString(ReCase(key).snakeCase, jsonEncode(value));
    }
  }
}

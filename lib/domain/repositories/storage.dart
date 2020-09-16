import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/system_user.dart';
import '../../domain/entities/setting.dart';

class StorageRepository {
  SharedPreferences _preferences;

  Future<void> load() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static const _systemUserKey = 'system_user';

  SystemUser get systemUser {
    final preference = _preferences.getString(_systemUserKey);
    if (preference == null) {
      return null;
    }

    return SystemUser.fromJson(json.decode(preference) as Map<String, dynamic>);
  }

  set systemUser(SystemUser user) => _preferences.setString(
        _systemUserKey,
        json.encode(
          user.toJson(includeToken: true),
        ),
      );

  static const _settingsKey = 'settings';

  List<Setting> get settings {
    final preference = _preferences.getString(_settingsKey);
    if (preference != null) {
      return (json.decode(preference) as List)
          // Tear-off won't work here
          // ignore: unnecessary_lambdas
          .map((s) => Setting.fromJson(s as Map<String, dynamic>))
          .toList();
    } else {
      return [];
    }
  }

  set settings(List<Setting> settings) => _preferences.setString(
        _settingsKey,
        json.encode(
          settings.map((s) => s.toJson()).toList(),
        ),
      );

  static const _logsKey = 'logs';

  String get logs => _preferences.getString(_logsKey) ?? '';

  set logs(String value) => _preferences.setString(_logsKey, value);

  void appendLogs(String value) {
    _preferences.setString(_logsKey, '$logs\n$value');
  }

  static const _lastDialedNumberKey = 'last_dialed_number';

  String get lastDialedNumber => _preferences.getString(_lastDialedNumberKey);

  set lastDialedNumber(String value) =>
      _preferences.setString(_lastDialedNumberKey, value);

  Future<void> clear() => _preferences.clear();
}

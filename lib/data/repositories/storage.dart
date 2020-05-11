import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/system_user.dart';
import '../../domain/entities/setting.dart';

import '../../domain/repositories/storage.dart';

class DeviceStorageRepository implements StorageRepository {
  SharedPreferences _preferences;

  @override
  Future<void> load() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static const _systemUserKey = 'system_user';

  @override
  SystemUser get systemUser {
    final string = _preferences.getString(_systemUserKey);
    if (string == null) {
      return null;
    }

    return SystemUser.fromJson(json.decode(string));
  }

  @override
  set systemUser(SystemUser user) => _preferences.setString(
        _systemUserKey,
        json.encode(
          user.toJson(includeToken: true),
        ),
      );

  static const _settingsKey = 'settings';

  @override
  List<Setting> get settings {
    final string = _preferences.get(_settingsKey);
    if (string != null) {
      return (json.decode(string) as List)
          // Tear-off won't work here
          // ignore: unnecessary_lambdas
          .map((s) => Setting.fromJson(s))
          .toList();
    } else {
      return [];
    }
  }

  @override
  set settings(List<Setting> settings) => _preferences.setString(
        _settingsKey,
        json.encode(
          settings.map((s) => s.toJson()).toList(),
        ),
      );

  static const _logsKey = 'logs';

  @override
  String get logs => _preferences.getString(_logsKey) ?? '';

  @override
  set logs(String value) => _preferences.setString(_logsKey, value);

  @override
  void appendLogs(String value) {
    _preferences.setString(_logsKey, '$logs\n$value');
  }

  static const _lastDialedNumberKey = 'last_dialed_number';

  @override
  String get lastDialedNumber => _preferences.getString(_lastDialedNumberKey);

  @override
  set lastDialedNumber(String value) =>
      _preferences.setString(_lastDialedNumberKey, value);

  @override
  Future<void> clear() => _preferences.clear();
}

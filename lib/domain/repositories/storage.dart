import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../entities/setting.dart';
import '../entities/system_user.dart';
import '../entities/voip_config.dart';

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
        user != null
            ? json.encode(
                user.toJson(),
              )
            : null,
      );

  static const _settingsKey = 'settings';

  List<Setting> get settings {
    final preference = _preferences.getString(_settingsKey);
    if (preference != null) {
      return (json.decode(preference) as List)
          .map((s) => Setting.fromJson(s as Map<String, dynamic>))
          .toList();
    } else {
      return [];
    }
  }

  set settings(List<Setting> settings) => _preferences.setString(
        _settingsKey,
        settings != null
            ? json.encode(
                settings.map((s) => s.toJson()).toList(),
              )
            : null,
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

  static const _callThroughCallsCountKey = 'call_through_calls_count';

  int get callThroughCallsCount =>
      _preferences.getInt(_callThroughCallsCountKey);

  set callThroughCallsCount(int value) =>
      _preferences.setInt(_callThroughCallsCountKey, value);

  static const _tokenKey = 'token';

  String get token => _preferences.getString(_tokenKey);

  set token(String value) => _preferences.setString(_tokenKey, value);

  static const _voipConfigKey = 'voip_config';

  VoipConfig get voipConfig {
    final preference = _preferences.getString(_voipConfigKey);
    if (preference == null) {
      return null;
    }

    return VoipConfig.fromJson(
      json.decode(preference) as Map<String, dynamic>,
    );
  }

  set voipConfig(VoipConfig user) => _preferences.setString(
        _voipConfigKey,
        user != null ? json.encode(user.toJson()) : null,
      );

  Future<void> clear() => _preferences.clear();

  Future<void> reload() => _preferences.reload();
}

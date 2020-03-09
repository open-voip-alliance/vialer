import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/system_user.dart';
import '../../domain/entities/setting.dart';

class Storage {
  final SharedPreferences _preferences;

  Storage._(this._preferences);

  static Future<Storage> load() async {
    return Storage._(await SharedPreferences.getInstance());
  }

  static const _systemUserKey = 'system_user';

  SystemUser get systemUser =>
      SystemUser.fromJson(json.decode(_preferences.getString(_systemUserKey)));

  set systemUser(SystemUser user) =>
      _preferences.setString(_systemUserKey, json.encode(user.toJson()));

  static const _apiTokenKey = 'api_token';

  String get apiToken => _preferences.getString(_apiTokenKey);

  set apiToken(String token) => _preferences.setString(_apiTokenKey, token);

  static const _settingsKey = 'settings';

  List<Setting> get settings =>
      (json.decode(_preferences.get(_settingsKey)) as List)
          // Tear-off won't work here
          // ignore: unnecessary_lambdas
          .map((s) => Setting.fromJson(s))
          .toList();

  set settings(List<Setting> settings) => _preferences.setString(
      _settingsKey, json.encode(settings.map((s) => s.toJson()).toList()));
}

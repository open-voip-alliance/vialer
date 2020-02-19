import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/system_user.dart';

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
}

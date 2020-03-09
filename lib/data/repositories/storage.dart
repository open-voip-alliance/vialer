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
  SystemUser get systemUser => SystemUser.fromJson(
        json.decode(
          _preferences.getString(_systemUserKey),
        ),
      );

  @override
  set systemUser(SystemUser user) => _preferences.setString(
        _systemUserKey,
        json.encode(
          user.toJson(),
        ),
      );

  static const _apiTokenKey = 'api_token';

  @override
  String get apiToken => _preferences.getString(_apiTokenKey);

  @override
  set apiToken(String token) => _preferences.setString(_apiTokenKey, token);

  static const _settingsKey = 'settings';

  @override
  List<Setting> get settings =>
      (json.decode(_preferences.get(_settingsKey)) as List)
          // Tear-off won't work here
          // ignore: unnecessary_lambdas
          .map((s) => Setting.fromJson(s))
          .toList();

  @override
  set settings(List<Setting> settings) => _preferences.setString(
        _settingsKey,
        json.encode(
          settings.map((s) => s.toJson()).toList(),
        ),
      );

  @override
  Future<void> clear() => _preferences.clear();
}

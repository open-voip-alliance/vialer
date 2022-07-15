import 'dart:convert';

import 'package:dartx/dartx.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../entities/setting.dart';
import '../entities/system_user.dart';
import '../entities/voip_config.dart';

class StorageRepository {
  late SharedPreferences _preferences;

  Future<void> load() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static const _systemUserKey = 'system_user';

  SystemUser? get systemUser {
    final preference = _preferences.getString(_systemUserKey);
    if (preference == null) {
      return null;
    }

    return SystemUser.fromJson(json.decode(preference) as Map<String, dynamic>);
  }

  set systemUser(SystemUser? user) => _preferences.setOrRemoveString(
        _systemUserKey,
        user != null ? json.encode(user.toJson()) : null,
      );

  static const _settingsKey = 'settings';

  List<Setting>? _settingsCache;

  List<Setting> get settings {
    if (_settingsCache == null) {
      final preference = _preferences.getString(_settingsKey);
      final settings = preference != null
          ? (json.decode(preference) as List)
              .map((s) => Setting.fromJson(s as Map<String, dynamic>))
              .filterNotNull()
              .toList()
          : <Setting>[];

      return _settingsCache = settings;
    } else {
      return _settingsCache!;
    }
  }

  /// If you need to `await` completion of the write, use [setSettings].
  set settings(List<Setting>? settings) => setSettings(settings);

  /// Set (replace) the settings. Future completes when writing is done.
  Future<void> setSettings(List<Setting>? settings) {
    _settingsCache = settings;

    return _preferences.setOrRemoveString(
      _settingsKey,
      settings != null
          ? json.encode(settings.map((s) => s.toJson()).toList())
          : null,
    );
  }

  static const _logsKey = 'logs';

  String? get logs => _preferences.getString(_logsKey);

  set logs(String? value) => _preferences.setOrRemoveString(_logsKey, value);

  Future<void> appendLogs(String value) async {
    await reload();
    _preferences.setString(_logsKey, '$logs\n$value');
  }

  static const _lastDialedNumberKey = 'last_dialed_number';

  String? get lastDialedNumber => _preferences.getString(_lastDialedNumberKey);

  set lastDialedNumber(String? value) =>
      _preferences.setOrRemoveString(_lastDialedNumberKey, value);

  static const _callThroughCallsCountKey = 'call_through_calls_count';

  int? get callThroughCallsCount =>
      _preferences.getInt(_callThroughCallsCountKey);

  set callThroughCallsCount(int? value) =>
      _preferences.setOrRemoveInt(_callThroughCallsCountKey, value);

  static const _pushTokenKey = 'push_token';

  String? get pushToken => _preferences.getString(_pushTokenKey);

  set pushToken(String? value) =>
      _preferences.setOrRemoveString(_pushTokenKey, value);

  static const _voipConfigKey = 'voip_config';

  VoipConfig? get voipConfig {
    final preference = _preferences.getString(_voipConfigKey);
    if (preference == null) {
      return null;
    }

    final config = VoipConfig.fromJson(
      json.decode(preference) as Map<String, dynamic>,
    );

    return config.isNotEmpty ? config.toNonEmptyConfig() : config;
  }

  set voipConfig(VoipConfig? user) => _preferences.setOrRemoveString(
        _voipConfigKey,
        user != null ? json.encode(user.toJson()) : null,
      );

  /// We store the last installed version so we can check if the user has
  /// updated the app, and if they have display the release notes to them.
  static const _lastInstalledVersionKey = 'last_installed_version';

  String? get lastInstalledVersion =>
      _preferences.getString(_lastInstalledVersionKey);

  set lastInstalledVersion(String? version) =>
      _preferences.setOrRemoveString(_lastInstalledVersionKey, version);

  /// We store whether the Recent page was shown, to display a dialog on the
  /// first show explaining where to find company calls.
  static const _shownRecentsKey = 'shown_recents';

  bool? get shownRecents => _preferences.getBool(_shownRecentsKey);

  set shownRecents(bool? shownRecents) =>
      _preferences.setOrRemoveBool(_shownRecentsKey, shownRecents);

  static const _isLoggedInSomewhereElseKey = 'is_logged_in_somewhere_else';

  bool? get isLoggedInSomewhereElse =>
      _preferences.getBool(_isLoggedInSomewhereElseKey);

  set isLoggedInSomewhereElse(bool? value) =>
      _preferences.setOrRemoveBool(_isLoggedInSomewhereElseKey, value);

  static const _loginTimeKey = 'login_time';

  DateTime? get loginTime => _preferences.getDateTime(_loginTimeKey);

  set loginTime(DateTime? value) =>
      _preferences.setOrRemoveDateTime(_loginTimeKey, value);

  static const _appRatingSurveyActionCountKey =
      'app_rating_survey_action_count';

  int? get appRatingSurveyActionCount =>
      _preferences.getInt(_appRatingSurveyActionCountKey);

  set appRatingSurveyActionCount(int? value) =>
      _preferences.setOrRemoveInt(_appRatingSurveyActionCountKey, value);

  static const _appRatingSurveyShownTimeKey = 'app_rating_survey_shown_time';

  DateTime? get appRatingSurveyShownTime =>
      _preferences.getDateTime(_appRatingSurveyShownTimeKey);

  set appRatingSurveyShownTime(DateTime? value) =>
      _preferences.setOrRemoveDateTime(_appRatingSurveyShownTimeKey, value);

  Future<void> clear() => _preferences.clear();

  Future<void> reload() => _preferences.reload();
}

extension on SharedPreferences {
  DateTime? getDateTime(String key) {
    final isoDate = getString(key);

    if (isoDate == null) return null;

    return DateTime.parse(isoDate);
  }

  Future<bool> setOrRemoveDateTime(String key, DateTime? value) {
    return setOrRemoveString(
      key,
      value?.toUtc().toIso8601String(),
    );
  }

  Future<bool> setOrRemoveString(String key, String? value) {
    if (value == null) {
      return remove(key);
    }

    return setString(key, value);
  }

  Future<bool> setOrRemoveInt(String key, int? value) {
    if (value == null) {
      return remove(key);
    }

    return setInt(key, value);
  }

  // ignore: avoid_positional_boolean_parameters
  Future<bool> setOrRemoveBool(String key, bool? value) {
    if (value == null) {
      return remove(key);
    }

    return setBool(key, value);
  }
}

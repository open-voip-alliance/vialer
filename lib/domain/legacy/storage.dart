import 'dart:async';
import 'dart:convert';

import 'package:dartx/dartx.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../calling/voip/destination.dart';
import '../colltacts/colltact_tab.dart';
import '../user/client.dart';
import '../user/permissions/user_permissions.dart';
import '../user/settings/app_setting.dart';
import '../user/settings/call_setting.dart';
import '../user/settings/settings.dart';
import '../user/user.dart';
import '../user_availability/colleagues/colleague.dart';
import '../voipgrid/client_voip_config.dart';
import '../voipgrid/user_voip_config.dart';

class StorageRepository {
  late SharedPreferences _preferences;

  Future<void> load() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // Value must stay the same, otherwise everything breaks.
  static const _userKey = 'system_user';

  User? get user {
    final userJson = _preferences.getJson(
          _userKey,
          (j) => j as Map<String, dynamic>,
        ) ??
        const {};

    User? user;

    // TODO: Remove legacy User deserialization eventually.
    // If the user has a 'settings' key, we know it's not a legacy user.
    if (userJson.containsKey('settings')) {
      user = _preferences.getJson(_userKey, User.fromJson);
    } else {
      final legacyUser = _preferences.getJson(
        _legacySettingsKey,
        (settingsJson) => _legacyUserFromJson(
          userJson,
          settingsJson as List<dynamic>,
        ),
      );

      // Legacy settings are deleted to prevent
      // overwriting new settings later on.
      if (legacyUser != null) {
        user = legacyUser;
        // Save to non-legacy user.
        this.user = user;
        _preferences.setOrRemoveString(_legacySettingsKey, null);
      }
    }

    if (_preferences.containsKey(_legacyVoipConfigKey)) {
      user = user?.copyWith(
        voip: _preferences.getJson<UserVoipConfig?, Map<String, dynamic>>(
          _legacyVoipConfigKey,
          UserVoipConfig.serializeFromJson,
        ),
      );
      this.user = user;
      _preferences.setOrRemoveString(_legacyVoipConfigKey, null);
    }

    if (_preferences.containsKey(_legacyServerConfigKey)) {
      user = user?.copyWith(
        client: user.client.copyWith(
          voip: _preferences.getJson(
            _legacyServerConfigKey,
            ClientVoipConfig.fromJson,
          ),
        ),
      );
      this.user = user;
      _preferences.setOrRemoveString(_legacyVoipConfigKey, null);
    }

    return user;
  }

  set user(User? user) =>
      _preferences.setOrRemoveJson(_userKey, user, User.toJson);

  // This value cannot change.
  static const _legacySettingsKey = 'settings';

  static const _logsKey = 'logs';

  String? get logs => _preferences.getString(_logsKey);

  set logs(String? value) => _preferences.setOrRemoveString(_logsKey, value);

  Future<void> appendLogs(String value) async {
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

  static const _remoteNotificationTokenKey = 'remote_notification_token';

  String? get remoteNotificationToken =>
      _preferences.getString(_remoteNotificationTokenKey);

  set remoteNotificationToken(String? value) =>
      _preferences.setOrRemoveString(_remoteNotificationTokenKey, value);

  static const _legacyVoipConfigKey = 'voip_config';

  /// We store the last installed version so we can check if the user has
  /// updated the app, and if they need to be shown the release notes.
  static const _lastInstalledVersionKey = 'last_installed_version';

  String? get lastInstalledVersion =>
      _preferences.getString(_lastInstalledVersionKey);

  set lastInstalledVersion(String? version) =>
      _preferences.setOrRemoveString(_lastInstalledVersionKey, version);

  static const _isLoggedInSomewhereElseKey = 'is_logged_in_somewhere_else';

  bool? get isLoggedInSomewhereElse =>
      _preferences.getBool(_isLoggedInSomewhereElseKey);

  set isLoggedInSomewhereElse(bool? value) =>
      _preferences.setOrRemoveBool(_isLoggedInSomewhereElseKey, value);

  static const _loginTimeKey = 'login_time';

  DateTime? get loginTime => _preferences.getDateTime(_loginTimeKey);

  set loginTime(DateTime? value) =>
      _preferences.setOrRemoveDateTime(_loginTimeKey, value);

  static const _lastCallRatingAskedTimeKey = 'last_call_rating_asked_time';

  DateTime? get lastCallRatingAskedTime =>
      _preferences.getDateTime(_lastCallRatingAskedTimeKey);

  set lastCallRatingAskedTime(DateTime? value) =>
      _preferences.setOrRemoveDateTime(_lastCallRatingAskedTimeKey, value);

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

  static const _legacyServerConfigKey = 'server_config';

  static const _previousSessionSettingsKey = 'previous_session_settings';

  Settings get previousSessionSettings =>
      _preferences.getJson(_previousSessionSettingsKey, Settings.fromJson) ??
      const Settings.empty();

  set previousSessionSettings(Settings? value) => _preferences.setOrRemoveJson(
        _previousSessionSettingsKey,
        value,
        Settings.toJson,
      );

  static const _colleaguesKey = 'colleagues';

  List<Colleague> get colleagues {
    final jsonString = _preferences.getString(_colleaguesKey);

    if (jsonString.isNullOrBlank) return const [];

    try {
      return (jsonDecode(jsonString!) as List<dynamic>)
          .map((e) => Colleague.fromJson(e as Map<String, dynamic>))
          .toList();
    } on Exception {
      return const [];
    }
  }

  set colleagues(List<Colleague> colleagues) => _preferences.setOrRemoveString(
        _colleaguesKey,
        jsonEncode(colleagues),
      );

  static const _grantedVoipgridPermissionsKey = 'granted_voipgrid_permissions';

  List<String> get grantedVoipgridPermissions => (jsonDecode(
              _preferences.getString(_grantedVoipgridPermissionsKey) ?? '[]')
          as List<dynamic>)
      .toRawPermissionsList();

  set grantedVoipgridPermissions(List<String> value) => _preferences
      .setOrRemoveString(_grantedVoipgridPermissionsKey, jsonEncode(value));

  static const _lastPeriodicIdentifyTime = 'last_periodic_identify_time';

  DateTime? get lastPeriodicIdentifyTime =>
      _preferences.getDateTime(_lastPeriodicIdentifyTime);

  set lastPeriodicIdentifyTime(DateTime? value) =>
      _preferences.setOrRemoveDateTime(_lastPeriodicIdentifyTime, value);

  static const _lastUserRefreshTime = 'last_user_refresh_time';

  DateTime? get lastUserRefreshedTime =>
      _preferences.getDateTime(_lastUserRefreshTime);

  set lastUserRefreshedTime(DateTime? value) =>
      _preferences.setOrRemoveDateTime(_lastUserRefreshTime, value);

  static const _userNumberKey = 'user_number';

  int? get userNumber => _preferences.getInt(_userNumberKey);

  set userNumber(int? number) =>
      _preferences.setOrRemoveInt(_userNumberKey, number);

  static const _availableDestinationsKey = 'available_destinations';

  List<Destination> get availableDestinations =>
      _preferences.getJson<List<Destination>, List<dynamic>>(
        _availableDestinationsKey,
        (list) => list.map(Destination.fromJson).toList(),
      ) ??
      [];

  set availableDestinations(List<Destination> destinations) =>
      _preferences.setOrRemoveJson<List<Destination>>(
        _availableDestinationsKey,
        destinations,
        (destinations) =>
            destinations.map((destination) => destination.toJson()).toList(),
      );

  Future<void> clear() => _preferences.clear();

  static const _hasCompletedOnboarding = 'has_completed_onboarding';

  bool? get hasCompletedOnboardingOrNull =>
      _preferences.getBool(_hasCompletedOnboarding);

  bool get hasCompletedOnboarding => hasCompletedOnboardingOrNull ?? false;

  set hasCompletedOnboarding(bool value) =>
      _preferences.setBool(_hasCompletedOnboarding, value);

  static const _currentColltactTabKey = 'current_colltact_tab';

  ColltactTab? get currentColltactTab {
    final name = _preferences.getString(_currentColltactTabKey);
    if (name == null) return null;
    return ColltactTab.values.firstOrNullWhere((t) => t.name == name);
  }

  set currentColltactTab(ColltactTab? value) =>
      _preferences.setOrRemoveString(_currentColltactTabKey, value?.name);

  Future<void> reload() => _preferences.reload();

  User? _legacyUserFromJson(
    Map<String, dynamic> userJson,
    List<dynamic> settingsJson,
  ) {
    if (userJson.isEmpty) return null;

    final settings = <SettingKey, Object>{};

    Iterable<String>? clientOutgoingNumbers;
    UserPermissions? permissions;

    for (final j in settingsJson) {
      final type = j['type'];
      final value = j['value'];

      assert(type != null);
      assert(value != null);

      // Make sure to add an explicit type cast if using `value` directly.
      switch (type) {
        case 'RemoteLoggingSetting':
          settings[AppSetting.remoteLogging] = value as bool;
          break;
        case 'ShowDialerConfirmPopupSetting':
          settings[AppSetting.showDialerConfirmPopup] = value as bool;
          break;
        case 'ShowSurveysSetting':
          settings[AppSetting.showSurveys] = value as bool;
          break;
        case 'BusinessNumberSetting':
        case 'OutgoingNumberSetting':
          settings[CallSetting.outgoingNumber] = OutgoingNumber.fromJson(value);
          break;
        case 'MobileNumberSetting':
          settings[CallSetting.mobileNumber] = value as String;
          break;
        case 'UsePhoneRingtoneSetting':
          settings[CallSetting.usePhoneRingtone] = value as bool;
          break;
        case 'UseVoipSetting':
          settings[CallSetting.useVoip] = value as bool;
          break;
        case 'ShowCallsInNativeRecentsSetting':
          settings[AppSetting.showCallsInNativeRecents] = value as bool;
          break;
        case 'AvailabilitySetting':
          settings[CallSetting.destination] = Destination.fromJson(
            value as Map<String, dynamic>,
          );
          break;
        case 'DndSetting':
          settings[CallSetting.dnd] = value as bool;
          break;
        case 'ShowClientCallsSetting':
          settings[AppSetting.showClientCalls] = value as bool;
          break;
        case 'UseMobileNumberAsFallbackSetting':
          settings[CallSetting.useMobileNumberAsFallback] = value as bool;
          break;
        case 'ClientOutgoingNumbersSetting':
          clientOutgoingNumbers = (value['numbers'] as List<dynamic>).cast();
          break;
        case 'VoipgridPermissionsSetting':
          permissions = const UserPermissions(
            canSeeClientCalls: false,
            canChangeMobileNumberFallback: false,
            canChangeTemporaryRedirect: false,
            canViewMobileNumberFallbackStatus: false,
            canViewVoicemailAccounts: false,
            canChangeOutgoingNumber: false,
            canViewColleagues: false,
            canViewVoipAccounts: false,
          );
          break;
      }
    }

    final appAccountUrlString = userJson['app_account'] as String?;
    final clientId = userJson['client_id'] as int;
    final clientUuid = userJson['client_uuid'] as String;
    final clientName = userJson['client_name'] as String;
    final clientUrlString = userJson['client'] as String;

    return User(
      uuid: userJson['uuid'] as String,
      email: userJson['email'] as String,
      firstName: userJson['first_name'] as String,
      lastName: userJson['last_name'] as String,
      token: userJson['token'] as String?,
      appAccountUrl:
          appAccountUrlString != null ? Uri.parse(appAccountUrlString) : null,
      client: Client(
        id: clientId,
        uuid: clientUuid,
        name: clientName,
        url: Uri.parse(clientUrlString),
        voip: ClientVoipConfig.fallback(),
        outgoingNumbers:
            clientOutgoingNumbers?.map(OutgoingNumber.new) ?? const [],
      ),
      settings: Settings.defaults.copyWithAll(settings),
      permissions: permissions ?? const UserPermissions(),
    );
  }
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

  T? getJson<T, J>(
    String key,
    T Function(J) fromJson,
  ) {
    final preference = getString(key);

    if (preference == null) return null;

    return fromJson(json.decode(preference) as J);
  }

  Future<bool> setOrRemoveJson<T>(
    String key,
    T? value,
    dynamic Function(T) toJson,
  ) {
    return setOrRemoveString(
      key,
      value != null ? json.encode(toJson(value)) : null,
    );
  }
}

extension RawPermissions on List<dynamic> {
  List<String> toRawPermissionsList() => filterNotNull()
      .map((permission) => permission.toString())
      .sorted()
      .toList();
}

import 'dart:async';
import 'dart:convert';

import 'package:dartx/dartx.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/calling/outgoing_number/outgoing_number.dart';
import '../../models/calling/voip/destination.dart';
import '../../models/colltacts/colltact_tab.dart';
import '../../models/colltacts/shared_contacts/shared_contact.dart';
import '../../models/relations/colleagues/colleague.dart';
import '../../models/user/settings/settings.dart';
import '../../models/user/user.dart';
import '../../repositories/voipgrid/user_permissions.dart';

@singleton
class StorageRepository {
  final SharedPreferences _preferences;

  const StorageRepository(this._preferences);

  // Value must stay the same, otherwise everything breaks.
  static const _userKey = 'system_user';

  User? get user {
    final json = _preferences.getJson(
      _userKey,
      (j) => j! as Map<String, dynamic>,
    );

    if (json == null) return null;

    // When upgrading to the new user permission setup, remove the old ones and
    // convert to the new set.
    // Remove when all of the users are upgraded.
    if (json.containsKey('permissions') &&
        json['permissions'] is Map<String, dynamic>) {
      final permissions = <Permission>{}..addAll(
          (json['permissions'] as Map<String, dynamic>).toNewPermissions(),
        );

      json.remove('permissions');

      return User.fromJson(json).copyWith(permissions: permissions);
    }

    return User.fromJson(json);
  }

  set user(User? user) => _preferences.setOrRemoveObject(_userKey, user);

  static const _logsKey = 'logs';

  String? get logs => _preferences.getString(_logsKey);

  set logs(String? value) => _preferences.setOrRemoveString(_logsKey, value);

  Future<void> appendLogs(String value) =>
      _preferences.setString(_logsKey, '$logs\n$value');

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

  static const _previousSessionSettingsKey = 'previous_session_settings';

  Settings get previousSessionSettings =>
      _preferences.containsKey(_previousSessionSettingsKey)
          ? jsonDecode(_preferences.getString(_previousSessionSettingsKey)!)
              as Settings
          : {};

  set previousSessionSettings(Settings? value) =>
      _preferences.setOrRemoveString(
        _previousSessionSettingsKey,
        jsonEncode(value),
      );

  static const _colleaguesKey = 'colleagues';

  List<Colleague> get colleagues {
    final jsonString = _preferences.getString(_colleaguesKey);

    if (jsonString.isNullOrBlank) return const [];

    try {
      return (jsonDecode(jsonString!) as List<dynamic>)
          .map((dynamic e) => Colleague.fromJson(e as Map<String, dynamic>))
          .toList();
    } on Exception {
      return const [];
    }
  }

  set colleagues(List<Colleague> colleagues) => _preferences.setOrRemoveString(
        _colleaguesKey,
        jsonEncode(colleagues),
      );

  static const _sharedContactsKey = 'sharedContacts';

  List<SharedContact> get sharedContacts {
    final jsonString = _preferences.getString(_sharedContactsKey);

    if (jsonString.isNullOrBlank) return const [];

    try {
      return (jsonDecode(jsonString!) as List<dynamic>)
          .map((dynamic e) => SharedContact.fromJson(e as Map<String, dynamic>))
          .toList();
    } on Exception {
      return const [];
    }
  }

  set sharedContacts(List<SharedContact> sharedContacts) =>
      _preferences.setOrRemoveString(
        _sharedContactsKey,
        jsonEncode(sharedContacts),
      );

  static const _grantedVoipgridPermissionsKey = 'granted_voipgrid_permissions';

  List<String> get grantedVoipgridPermissions => (jsonDecode(
        _preferences.getString(_grantedVoipgridPermissionsKey) ?? '[]',
      ) as List<dynamic>)
          .toRawPermissionsList();

  set grantedVoipgridPermissions(List<String> value) => _preferences
      .setOrRemoveString(_grantedVoipgridPermissionsKey, jsonEncode(value));

  static const _lastPeriodicIdentifyTime = 'last_periodic_identify_time';

  DateTime? get lastPeriodicIdentifyTime =>
      _preferences.getDateTime(_lastPeriodicIdentifyTime);

  set lastPeriodicIdentifyTime(DateTime? value) =>
      _preferences.setOrRemoveDateTime(_lastPeriodicIdentifyTime, value);

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

  static const _hasCompletedOnboarding = 'has_completed_onboarding';

  bool? get hasCompletedOnboardingOrNull =>
      _preferences.getBool(_hasCompletedOnboarding);

  bool get hasCompletedOnboarding => hasCompletedOnboardingOrNull ?? false;

  set hasCompletedOnboarding(bool value) =>
      unawaited(_preferences.setBool(_hasCompletedOnboarding, value));

  static const _currentColltactTabKey = 'current_colltact_tab';

  ColltactTab? get currentColltactTab {
    final name = _preferences.getString(_currentColltactTabKey);
    if (name == null) return null;
    return ColltactTab.values.firstOrNullWhere((t) => t.name == name);
  }

  set currentColltactTab(ColltactTab? value) =>
      _preferences.setOrRemoveString(_currentColltactTabKey, value?.name);

  static const _recentOutgoingNumbers = 'recent_outgoing_numbers';

  Iterable<OutgoingNumber> get recentOutgoingNumbers =>
      _preferences.getJson<Iterable<OutgoingNumber>, List<dynamic>>(
        _recentOutgoingNumbers,
        (list) => list.map(OutgoingNumber.fromJson).toIterable(),
      ) ??
      Iterable.empty();

  set recentOutgoingNumbers(Iterable<OutgoingNumber> numbers) =>
      _preferences.setOrRemoveJson<Iterable<OutgoingNumber>>(
        _recentOutgoingNumbers,
        numbers,
        (numbers) => numbers.map(OutgoingNumber.serializeToJson).toList(),
      );

  static const _doNotShowOutgoingNumberSelector =
      'do_not_show_outgoing_number_selector';

  bool? get doNotShowOutgoingNumberSelectorOrNull =>
      _preferences.getBool(_doNotShowOutgoingNumberSelector);

  bool get doNotShowOutgoingNumberSelector =>
      _preferences.getBool(_doNotShowOutgoingNumberSelector) ?? false;

  set doNotShowOutgoingNumberSelector(bool value) => unawaited(
        _preferences.setBool(
          _doNotShowOutgoingNumberSelector,
          value,
        ),
      );

  static const _isUsingScreenReader = 'is_using_screen_reader';

  bool? get _isUsingScreenReaderOrNull =>
      _preferences.getBool(_isUsingScreenReader);

  bool get isUsingScreenReader => _isUsingScreenReaderOrNull ?? false;

  set isUsingScreenReader(bool value) =>
      unawaited(_preferences.setBool(_isUsingScreenReader, value));

  Future<void> clear() => _preferences.clear();

  Future<void> reload() => _preferences.reload();
}

extension on SharedPreferences {
  DateTime? getDateTime(String key) {
    final isoDate = getString(key);

    if (isoDate == null) return null;

    return DateTime.parse(isoDate);
  }

  void setOrRemoveDateTime(String key, DateTime? value) {
    setOrRemoveString(
      key,
      value?.toUtc().toIso8601String(),
    );
  }

  void setOrRemoveString(String key, String? value) {
    if (value == null) {
      unawaited(remove(key));
      return;
    }

    unawaited(setString(key, value));
  }

  void setOrRemoveInt(String key, int? value) {
    if (value == null) {
      unawaited(remove(key));
      return;
    }

    unawaited(setInt(key, value));
  }

  // ignore: avoid_positional_boolean_parameters
  void setOrRemoveBool(String key, bool? value) {
    if (value == null) {
      unawaited(remove(key));
      return;
    }

    unawaited(setBool(key, value));
  }

  T? getJson<T, J>(
    String key,
    T Function(J) fromJson,
  ) {
    final preference = getString(key);

    if (preference == null) return null;

    return fromJson(json.decode(preference) as J);
  }

  void setOrRemoveJson<T>(
    String key,
    T? value,
    dynamic Function(T) toJson,
  ) {
    setOrRemoveString(
      key,
      value != null ? json.encode(toJson(value)) : null,
    );
  }

  /// Uses [jsonEncode] which requires a `.toJson()` to be implemented. This
  /// should automatically work for any Freezed model that has setup json
  /// encoding.
  void setOrRemoveObject(String key, dynamic object) => setOrRemoveString(
        key,
        jsonEncode(object),
      );
}

extension RawPermissions on List<dynamic> {
  List<String> toRawPermissionsList() => filterNotNull()
      .map((permission) => permission.toString())
      .sorted()
      .toList();
}

extension NewPermissions on Map<String, dynamic> {
  Set<Permission> toNewPermissions() {
    final permissions = this;
    return {
      if (permissions['canSeeClientCalls'] as bool? ?? false)
        Permission.canSeeClientCalls,
      if (permissions['canChangeMobileNumberFallback'] as bool? ?? false)
        Permission.canChangeMobileNumberFallback,
      if (permissions['canChangeTemporaryRedirect'] as bool? ?? false)
        Permission.canChangeMobileNumberFallback,
      if (permissions['canViewVoicemailAccounts'] as bool? ?? false)
        Permission.canViewVoicemailAccounts,
      if (permissions['canChangeOutgoingNumber'] as bool? ?? false)
        Permission.canChangeOutgoingNumber,
      if (permissions['canViewColleagues'] as bool? ?? false)
        Permission.canViewColleagues,
      if (permissions['canViewVoipAccounts'] as bool? ?? false)
        Permission.canViewVoipAccounts,
      if (permissions['canViewDialPlans'] as bool? ?? false)
        Permission.canViewDialPlans,
      if (permissions['canViewStats'] as bool? ?? false)
        Permission.canViewStats,
      if (permissions['canChangeOpeningHours'] as bool? ?? false)
        Permission.canChangeOpeningHours,
    };
  }
}

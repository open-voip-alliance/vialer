import 'dart:io';

import 'package:native_shared_preferences/native_shared_preferences.dart';

/// This allows access to the shared preferences of the legacy apps, to
/// allow importing of data into this app. This should only be used to
/// facilitate the seamless upgrade for users.
class LegacyStorageRepository {
  late NativeSharedPreferences _preferences;

  String get _legacyTokenKey => Platform.isAndroid ? 'loginToken' : 'APIToken';

  String get _legacyEmailAddressKey =>
      Platform.isAndroid ? 'username' : 'Email';

  Future<void> load() async {
    _preferences = await NativeSharedPreferences.getInstance();
  }

  String? get token => _preferences.getString(_legacyTokenKey);

  String? get emailAddress => _preferences.getString(_legacyEmailAddressKey);

  void clear() {
    // The iOS legacy app does not have a separate shared preferences file so
    // we just want to remove the specific keys.
    if (Platform.isIOS) {
      _preferences.remove(_legacyTokenKey);
      _preferences.remove(_legacyEmailAddressKey);
    } else {
      _preferences.clear();
    }
  }
}

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:vialer/domain/user/settings/app_setting.dart';
import 'package:vialer/domain/user/settings/call_setting.dart';
import 'package:vialer/domain/user/settings/settings.dart';

class SettingsRepository {
  final SharedPreferences _storage;

  const SettingsRepository(this._storage);

  Map<SettingKey, Object> get _defaults => {
        ...AppSetting.defaultValues,
        ...CallSetting.defaultValues,
      };

  T? getOrNull<T extends Object>(SettingKey<T> key) {
    final value = _storage.get(key.asSharedPreferencesKey());
    final type = key.valueType;

    if (type == String) return value.toString() as T?;

    if (_isPrimitive(key)) return jsonDecode(value.toString()) as T?;

    return key.valueFromJson(jsonDecode(value.toString()));
  }

  T get<T extends Object>(SettingKey<T> key) => getOrNull(key)!;

  Future<bool> change(SettingKey key, Object value) => _storage.setString(
        key.asSharedPreferencesKey(),
        value is String ? value : jsonEncode(key.valueToJson(value)),
      );

  bool _isPrimitive<T extends Object>(SettingKey<T> key) {
    final type = key.valueType;

    return type == String || type == bool || type == int || type == double;
  }

  /// Attempts to load any default settings if a value for these doesn't already
  /// exist.
  Future<void> loadDefaultSettings() async => _defaults.forEach(
        (key, value) async {
          if (!_storage.containsKey(key.asSharedPreferencesKey())) {
            await change(key, value);
          }
        },
      );
}

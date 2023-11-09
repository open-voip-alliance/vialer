import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vialer/domain/user/settings/app_setting.dart';
import 'package:vialer/domain/user/settings/call_setting.dart';
import 'package:vialer/domain/user/settings/settings.dart';

@singleton
class SettingsRepository {
  final SharedPreferences _storage;

  const SettingsRepository(this._storage);

  Map<SettingKey, Object?> get _defaults => {
        ...AppSetting.defaultValues,
        ...CallSetting.defaultValues,
      };

  T? getOrNull<T extends Object>(SettingKey<T> key) {
    if (!has(key)) return _defaultValue(key);

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

  /// Checks if we have a stored, custom value. Will return FALSE even if the
  /// [get] method might return a default value.
  bool has<T extends Object>(SettingKey<T> key) =>
      _storage.containsKey(key.asSharedPreferencesKey());

  T? _defaultValue<T extends Object>(SettingKey<T> key) {
    final defaultValue = _defaults[key];

    assert(
      defaultValue is T?,
      'The default value for [$key] must match the type of the setting. In'
      'this case the setting has a type of [${key.valueType}] but the default '
      'value provided is [${defaultValue.runtimeType}]. Update the defaultValue'
      'in the setting file.',
    );

    return defaultValue is T? ? defaultValue : null;
  }

  bool _isPrimitive<T extends Object>(SettingKey<T> key) {
    final type = key.valueType;

    return type == String || type == bool || type == int || type == double;
  }
}

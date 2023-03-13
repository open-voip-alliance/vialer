import 'dart:async';

import 'package:collection/collection.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import 'app_setting.dart';
import 'call_setting.dart';

typedef ValueToJson<T> = dynamic Function(T value);
typedef ValueFromJson<T> = T Function(dynamic json);

/// Unordered collection of any type of property
/// that can be changed by the user.
///
/// Values cannot be null.
@immutable
class Settings {
  final Map<SettingKey, Object> _map;

  Iterable<MapEntry<SettingKey, Object>> get entries => _map.entries;

  const Settings(Map<SettingKey, Object> map) : _map = map;

  const Settings.empty() : this(const {});

  Settings.defaults()
      : this(
          {
            ...AppSetting.defaultValues,
            ...CallSetting.defaultValues,
          },
        );

  T? getOrNull<T extends Object>(SettingKey<T> key) =>
      (_map[key] as T?) ??
      // Only retrieve from defaults if this instance itself is not .defaults()
      (!identical(this, Settings.defaults())
          ? Settings.defaults().getOrNull(key)
          : null);

  T get<T extends Object>(SettingKey<T> key) => getOrNull(key)!;

  Settings getAll(Iterable<SettingKey> keys) => Settings(
        Map.fromEntries(
          _map.entries.filter((e) => keys.contains(e.key)),
        ),
      );

  bool get isEmpty => _map.isEmpty;

  /// Returns a copy of this [Settings] with all values being overridden by
  /// [other].
  Settings copyFrom(Settings other) => copyWithAll(other._map);

  /// Returns a copy of this [Settings] with the given setting changed.
  Settings copyWith<T extends Object>(SettingKey<T> key, T value) {
    // If <T> is omitted, Dart does not infer that `value` must be the same type
    // as the specified <T> of `key`.
    if (value.runtimeType != key.valueType) {
      debugPrint(
        'value.runtimeType [${value.runtimeType}] does '
        'not match key.valueType [${key.valueType}]',
      );
    }
    return Settings({
      ..._map,
      key: value,
    });
  }

  /// Returns a copy of this [Settings] with the given settings changed.
  Settings copyWithAll<T extends Object>(Map<SettingKey, Object> values) {
    return Settings({
      ..._map,
      ...values,
    });
  }

  /// Returns the keys and values of the settings that are different between
  /// `this` and [other].
  ///
  /// Key-value pairs that are in [other] but no in [this] are considered
  /// changed.
  ///
  /// If a value is different in [other] compared to [this], it's
  /// considered changed.
  Settings diff(Settings other) {
    final thisKeys = keys;
    final otherKeys = other.keys;

    final newKeys = otherKeys.difference(thisKeys);
    final commonKeys = thisKeys.intersection(otherKeys);

    return Settings(
      Map.fromEntries(
        commonKeys.mapNotNull((key) {
          final oldValue = get(key);
          final newValue = other.get(key);
          if (oldValue == newValue) return null;
          return MapEntry(key, newValue);
        }).followedBy(
          newKeys.map(
            (key) => MapEntry(key, other.get(key)),
          ),
        ),
      ),
    );
  }

  bool hasKey(SettingKey key) => _map.containsKey(key);

  bool hasKeys(Iterable<SettingKey> keys) => keys.all(_map.containsKey);

  bool hasAnyKeyOf(Iterable<SettingKey> keys) => keys.any(_map.containsKey);

  /// Runs the given [block] if [key] has an associated value.
  FutureOr<void> runIfPresent<T extends Object>(
    SettingKey<T> key,
    FutureOr<void> Function(SettingKey<T> key, T value) block,
  ) {
    final value = getOrNull<T>(key);
    if (value == null) return null;

    return block(key, value);
  }

  /// Whether all possible setting keys have values associated with them.
  bool get isComplete => possibleKeys.difference(keys).isEmpty;

  Set<SettingKey> get keys => Set.unmodifiable(_map.keys);

  static const Set<SettingKey> possibleKeys = {
    ...AppSetting.values,
    ...CallSetting.values,
  };

  @override
  bool operator ==(Object other) {
    if (other is! Settings) return false;

    return const MapEquality().equals(_map, other._map);
  }

  @override
  int get hashCode => _map.hashCode;

  @override
  String toString() => 'Settings($_map)';

  static dynamic toJson(Settings value) => Map.fromEntries(
        value._map.entries.map(
          (e) => MapEntry(
            e.key.toJson(),
            e.key.valueToJson(e.value),
          ),
        ),
      );

  static Settings fromJson(Map<String, dynamic> json) {
    return Settings(
      Map.fromEntries(
        json.entries
            .where((e) => SettingKey.fromJson(e.key, possibleKeys) != null)
            .map((e) {
          final key = SettingKey.fromJson(e.key, possibleKeys);
          final value = key!.valueFromJson(e.value);

          return MapEntry(key, value);
        }),
      ),
    );
  }
}

mixin SettingKey<T extends Object> on Enum {
  Type get valueType => T;

  String toJson() => toString();

  /// Only returns `null` when the key isn't found.
  /// Most likely in the situation the key isn't used anymore.
  static K? fromJson<K extends SettingKey>(
    String json,
    Iterable<K> all,
  ) =>
      all.firstWhereOrNull((k) => k.toString() == json);

  @protected
  SettingValueJsonConverter<T>? get valueJsonConverter => null;

  dynamic valueToJson(T value) =>
      valueJsonConverter?.toJson(value) ?? _primitiveValueToJson(value);

  T valueFromJson(dynamic json) =>
      valueJsonConverter?.fromJson(json) ?? _primitiveValueFromJson(json);

  dynamic _primitiveValueToJson(T value) {
    _assertIsPrimitive();
    return value;
  }

  T _primitiveValueFromJson(dynamic json) {
    _assertIsPrimitive();
    return json as T;
  }

  void _assertIsPrimitive() {
    assert(
      T == bool || T == String || T == int || T == double || T == Null,
      'Setting value is not a primitive and '
      'does not have a toJson and fromJson defined',
    );
  }
}

class SettingValueJsonConverter<T> extends JsonConverter<T, dynamic> {
  final ValueToJson<T> _toJson;
  final ValueFromJson<T> _fromJson;

  const SettingValueJsonConverter(this._toJson, this._fromJson);

  @override
  dynamic toJson(T object) => _toJson(object);

  @override
  T fromJson(dynamic json) => _fromJson(json);
}

/// Shorthand for use in [SettingKey] enum value constructors.
typedef Converters<T> = SettingValueJsonConverter<T>;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:recase/recase.dart';

typedef ValueToJson<T> = dynamic Function(T value);
typedef ValueFromJson<T> = T Function(dynamic json);
typedef Settings = Map<SettingKey, Object>;

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

  String asSharedPreferencesKey() => ReCase(toString()).snakeCase;
}

class SettingValueJsonConverter<T> extends JsonConverter<T, dynamic> {
  const SettingValueJsonConverter(this._toJson, this._fromJson);

  final ValueToJson<T> _toJson;
  final ValueFromJson<T> _fromJson;

  @override
  dynamic toJson(T object) => _toJson(object);

  @override
  T fromJson(dynamic json) => _fromJson(json);
}

/// Shorthand for use in [SettingKey] enum value constructors.
typedef Converters<T> = SettingValueJsonConverter<T>;

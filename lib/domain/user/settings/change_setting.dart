import 'dart:async';

import '../../use_case.dart';
import 'change_settings.dart';
import 'settings.dart';

class ChangeSettingUseCase extends UseCase {
  final _changeSettings = ChangeSettingsUseCase();

  Future<SettingChangeResult> call<T extends Object>(
    SettingKey<T> key,
    T value,
  ) {
    // Because this is often called with <T> being omitted, in which case Dart
    // does not infer T based on the given key, we assert  whether the type
    // matches with what we'd expect from the key.
    assert(value.runtimeType == key.valueType);
    return _changeSettings(Settings({key: value})).then((r) {
      if (r.failed.contains(key)) return SettingChangeResult.failed;
      if (r.changed.contains(key)) return SettingChangeResult.changed;
      return SettingChangeResult.unchanged;
    });
  }
}

enum SettingChangeResult {
  /// The value was already the same as it was supposed to change to.
  unchanged,
  changed,
  failed,
}

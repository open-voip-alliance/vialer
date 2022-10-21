import 'dart:async';

import 'package:meta/meta.dart';

import '../../event/event_bus.dart';
import 'settings.dart';

@immutable
class SettingChanged<T extends Object> {
  final SettingKey<T> key;
  final T oldValue;
  final T newValue;

  const SettingChanged(
    this.key,
    this.oldValue,
    this.newValue,
  );
}

extension ObservingSettingChange on Stream {
  StreamSubscription<SettingChanged> onSettingChange<T extends Object>(
    SettingKey<T> key,
    void onData(T oldValue, T value)?, {
    Function? onError,
    void onDone()?,
    bool? cancelOnError,
  }) =>
      // We cannot check for SettingChange<T>, because they are broadcast
      // as SettingChange<dynamic>.
      on<SettingChanged>(
        (event) {
          if (event.key != key) return;
          onData?.call(event.oldValue as T, event.newValue as T);
        },
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );
}

import 'dart:async';

import 'package:meta/meta.dart';
import 'package:vialer/data/models/user/settings/settings.dart';

import '../../event/event_bus.dart';

@immutable
class SettingChangedEvent<T extends Object> implements EventBusEvent {
  const SettingChangedEvent(
    this.key,
    this.oldValue,
    this.newValue,
  );

  final SettingKey<T> key;
  final T oldValue;
  final T newValue;
}

extension ObservingSettingChange on EventBusObserver {
  StreamSubscription<SettingChangedEvent> onSettingChange<T extends Object>(
    SettingKey<T> key,
    void Function(T oldValue, T value)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) =>
      // We cannot check for SettingChange<T>, because they are broadcast
      // as SettingChange<dynamic>.
      on<SettingChangedEvent>(
        (event) {
          if (event.key != key) return;
          onData?.call(event.oldValue as T, event.newValue as T);
        },
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );
}

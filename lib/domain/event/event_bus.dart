import 'dart:async';
import 'package:rxdart/rxdart.dart';

abstract class EventBusEvent {}

typedef EventBusObserver = Stream<EventBusEvent>;
typedef EventBus = StreamController<EventBusEvent>;

extension Broadcasting on EventBus {
  void broadcast(EventBusEvent event) => add(event);
}

extension Observing on EventBusObserver {
  StreamSubscription<T> on<T>(
    void Function(T event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
    Duration debounceTime = Duration.zero,
  }) =>
      where((dynamic event) => event is T)
          .cast<T>()
          .debounceTime(debounceTime)
          .listen(
            onData,
            onError: onError,
            onDone: onDone,
            cancelOnError: cancelOnError,
          );
}

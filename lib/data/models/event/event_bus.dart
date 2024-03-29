import 'dart:async';

abstract class EventBusEvent {}

typedef EventBusObserver = Stream<EventBusEvent>;
typedef EventBus = StreamController<EventBusEvent>;

extension Broadcasting on EventBus {
  void broadcast(EventBusEvent event) => add(event);
}

// When using within a widget, you should always use the EventBusListener widget
// while will handle disposing of the listener properly.
extension Observing on EventBusObserver {
  StreamSubscription<T> on<T extends EventBusEvent>(
    void Function(T event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) =>
      where((dynamic event) => event is T).cast<T>().listen(
            onData,
            onError: onError,
            onDone: onDone,
            cancelOnError: cancelOnError,
          );
}

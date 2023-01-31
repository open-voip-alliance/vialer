import 'dart:async';

typedef EventBusObserver = Stream;
typedef EventBus = StreamController;

extension Broadcasting on StreamController {
  void broadcast(event) => add(event);
}

extension Observing on Stream {
  StreamSubscription<T> on<T>(
    void Function(T event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) =>
      where((event) => event is T).cast<T>().listen(
            onData,
            onError: onError,
            onDone: onDone,
            cancelOnError: cancelOnError,
          );
}

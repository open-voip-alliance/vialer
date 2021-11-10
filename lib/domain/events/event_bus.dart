import 'dart:async';

typedef EventBusObserver = Stream;
typedef EventBus = StreamController;

extension Broadcasting on StreamController {
  void broadcast(event) => add(event);
}

extension Observing on Stream {
  void on<T>(
    void onData(T event)?, {
    Function? onError,
    void onDone()?,
    bool? cancelOnError,
  }) =>
      where((event) => event is T).cast<T>().listen(
            onData,
            onError: onError,
            onDone: onDone,
            cancelOnError: cancelOnError,
          );
}

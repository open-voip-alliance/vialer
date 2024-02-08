import '../../../../dependency_locator.dart';
import '../../../models/event/event_bus.dart';
import '../payloads/payload.dart';

abstract class ResgateListener<T extends ResgatePayload> {
  late final _eventBus = dependencyLocator<EventBus>();

  Type get type => T;

  /// The payload that was handled last by the listener.
  ///
  /// Listeners will not be delivered payloads they are identical to the
  /// previous one unless they opt out of this by setting
  /// [handleEveryPayload] to [true].
  ResgatePayload? previous;

  /// Override this to ensure every payload is handled by the listener,
  /// whether it is a new one or not. See [previous] for more information.
  bool handleEveryPayload = false;

  /// Determine if we should handle a specific event, by default this will only
  /// accept events of type [T] but can be overridden for more complex behavior
  /// if necessary.
  bool shouldHandle(ResgatePayload payload) => payload is T;

  /// The WebSocket received a message of the given type and this listener
  /// should handle the message.
  Future<void> handle(T payload);

  /// Called when a request has been made to refresh the websocket, this will
  /// happen before the refresh occurs. This is particularly useful if some
  /// data is being persisted, when a refresh happens, all this data can be
  /// cleared before the new data is received on first connect.
  Future<void> onRefreshRequested() async {}

  /// Called whenever we connect to the WebSocket.
  ///
  /// This should rarely be used instead see [onRefreshRequested].
  Future<void> onConnect() async {}

  /// Called whenever we disconnect from the WebSocket.
  ///
  /// This should rarely be used instead see [onRefreshRequested].
  Future<void> onDisconnect() async {}

  /// A helper method to broadcast an event on the main [EventBus].
  void broadcast(EventBusEvent e) => _eventBus.broadcast(e);

  /// The topic that this listener will subscribe to, this should be in the form
  /// of an RID.
  String get resourceToSubscribeTo;

  /// The events that this listener will actually be executed for. For example
  /// you might subscribe to `availability.user` but you will receive events
  /// with an RID of `availability.user.user-id-1234`. This property should
  /// provide a [RegExp] that will match to the latter or it will not
  /// be called when such an event is received.
  RegExp get resourceToHandle => RegExp(resourceToSubscribeTo);
}

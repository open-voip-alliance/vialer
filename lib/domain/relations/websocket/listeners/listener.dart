import 'package:vialer/domain/relations/websocket/payloads/payload.dart';

import '../../../../dependency_locator.dart';
import '../../../event/event_bus.dart';

abstract class Listener<T extends Payload> {
  late final _eventBus = dependencyLocator<EventBus>();

  Type get type => T;

  /// Determine if we should handle a specific event, by default this will only
  /// accept events of type [T] but can be overridden for more complex behavior
  /// if necessary.
  bool shouldHandle(Payload payload) => payload is T;

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
}

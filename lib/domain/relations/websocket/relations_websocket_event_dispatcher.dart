import 'dart:convert';

import 'package:vialer/app/util/loggable.dart';
import 'package:vialer/domain/relations/websocket/listeners/listener.dart';
import 'package:vialer/domain/relations/websocket/listeners/logged_in_user_availability_changed_handler.dart';
import 'package:vialer/domain/relations/websocket/listeners/update_destinations_with_is_online.dart';
import 'package:vialer/domain/relations/websocket/payloads/payload.dart';
import 'package:vialer/domain/relations/websocket/payloads/user_devices_changed.dart';

import 'listeners/colleague_update_handler.dart';
import 'payloads/user_availability_changed.dart';

typedef Deserializer = Payload Function(Map<String, dynamic>);

class RelationsWebSocketEventDispatcher {
  /// A [Listener] will handle any events that they are capable of handling,
  /// you can register multiple handlers for the same event.
  final _listeners = <Listener>[
    LoggedInUserAvailabilityChangedHandler(),
    ColleagueUpdateHandler(),
    UpdateDestinationWithIsOnline(),
  ];

  /// Register any payloads here that we want to handle, this is a mapping
  /// between the event name (which we receive from the WebSocket) and a
  /// [Serializer] function that will map it to an object.
  final _payloads = <String, Deserializer>{
    'user_availability_changed': UserAvailabilityChangedPayload.fromJson,
    'user_devices_changed': UserDevicesChangedPayload.fromJson,
  };

  void onData(dynamic data) async {
    final event = jsonDecode(data as String) as Map<String, dynamic>;

    final object = event['payload'] as Map<String, dynamic>;

    final name = event['name'];

    if (!_payloads.containsKey(name)) {
      logger.info(
        'Received Relations WebSocket message [$name] but do not have a '
        'corresponding payload registered. Ignoring [$name].',
      );
      return;
    }

    final payload = _payloads[name]!(object);

    final listeners = _listeners.listeningFor(payload);

    if (listeners.isEmpty) {
      logger.warning(
        'There is a registered payload [${payload.runtimeType}] but there is '
        'no corresponding listener. Can this payload be removed?',
      );
      return;
    }

    for (final listener in listeners) {
      if (listener.shouldSkipHandling(payload)) continue;
      listener.handle(payload);
      listener.previous = payload;
    }
  }

  Future<void> performOnEachListener(ListenerCallback callback) =>
      Future.forEach(
        _listeners,
        (listener) => callback(listener),
      );
}

typedef ListenerCallback = Future<void> Function(Listener);

extension on List<Listener> {
  List<Listener> listeningFor(Payload payload) =>
      where((l) => l.shouldHandle(payload)).toList();
}

extension on Listener {
  bool shouldSkipHandling(Payload payload) =>
      !handleEveryPayload && previous == payload;
}

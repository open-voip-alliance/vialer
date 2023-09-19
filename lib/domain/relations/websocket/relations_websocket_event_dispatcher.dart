import 'dart:convert';

import 'package:vialer/app/util/loggable.dart';
import 'package:vialer/dependency_locator.dart';
import 'package:vialer/domain/event/event_bus.dart';
import 'package:vialer/domain/relations/websocket/events/user_devices_changed.dart';
import 'package:vialer/domain/relations/websocket/events/user_dnd_changed.dart';

import 'events/user_availability_changed.dart';

class RelationsWebsocketEventDispatcher {
  final _eventBus = dependencyLocator<EventBus>();

  final deserializers = {
    'user_availability_changed': UserAvailabilityChangedPayload.fromJson,
    'user_dnd_changed': UserDndChangedPayload.fromJson,
    'user_devices_changed': UserDevicesChangedPayload.fromJson,
  };

  void onData(dynamic data) async {
    final event = jsonDecode(data as String) as Map<String, dynamic>;

    final object = event['payload'] as Map<String, dynamic>;

    final name = event['name'];

    if (!deserializers.containsKey(name)) {
      logger.info('Ignoring [$name] as we do not have a handler for it');
      return;
    }

    final payload = deserializers[name]!(object);

    _eventBus.broadcast(payload);
  }
}

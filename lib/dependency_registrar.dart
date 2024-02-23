import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vialer/presentation/util/pigeon.dart';

import 'data/models/event/event_bus.dart';

/// Register any third-party objects in the container, this is any code that
/// we do not control and therefore cannot annotate.
@module
abstract class ThirdPartyRegistrar {
  @singleton
  EventBus get eventBus => StreamController<EventBusEvent>.broadcast();

  @singleton
  EventBusObserver getEventBusObserver(EventBus eventBus) => eventBus.stream;

  @preResolve
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();
}

@module
abstract class PigeonRegistrar {
  @singleton
  SharedContacts getSharedContacts() => SharedContacts();
}

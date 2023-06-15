import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../dependency_locator.dart';
import '../../domain/event/event_bus.dart';

class EventBusListener<T extends EventBusEvent> extends StatefulWidget {
  const EventBusListener({
    Key? key,
    required this.listener,
    required this.child,
  }) : super(key: key);

  final void Function(T event) listener;
  final Widget child;

  @override
  State<EventBusListener<T>> createState() => _EventBusListenerState<T>();
}

class _EventBusListenerState<T extends EventBusEvent>
    extends State<EventBusListener<T>> {
  final _eventBus = dependencyLocator<EventBusObserver>();
  late final StreamSubscription<T> _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = _eventBus.on<T>((e) => widget.listener(e));
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.cancel();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

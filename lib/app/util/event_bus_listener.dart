import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../dependency_locator.dart';
import '../../domain/event/event_bus.dart';

/// Provides a wrapper around listening for an [EventBusEvent] that does not
/// require management of the listener. This will automatically start and stop
/// listening so `if (mounted)` calls are not necessary when receiving
/// an event.
///
/// This is only for when events need to be listened for in the widget tree, if
/// they happen in a cubit or anywhere else the listener must be properly
/// cleaned-up manually.
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
  late final _eventBus = dependencyLocator<EventBusObserver>();
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

extension RebuildOnEvent on State {
  /// A helper that can be passed into [EventBusListener] that will simply cause
  /// the widget to be re-built when any event is received.
  ///
  /// This should only be used when you do not care about the content of the
  /// event, only that the event occurred.
  // ignore: invalid_use_of_protected_member
  void rebuildOnEvent<T extends EventBusEvent>(T event) => setState(() {});
}

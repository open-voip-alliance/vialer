import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vialer/data/API/authentication/user_logged_in.dart';
import 'package:vialer/dependency_locator.dart';
import 'package:vialer/domain/usecases/authentication/user_was_logged_out.dart';

import '../../../../../data/models/event/event_bus.dart';
import '../../../../../data/models/relations/websocket/relations_web_socket.dart';
import '../../../shared/controllers/connectivity_checker/cubit.dart';
import '../../../util/widgets_binding_observer_registrar.dart';

/// This connects the [RelationsWebSocket] with the app lifecycle and events
/// to properly disconnect or connect when appropriate, for example when
/// the app is launched.
class RelationsWebSocketManager extends StatefulWidget {
  const RelationsWebSocketManager._(this.child);

  final Widget child;

  static Widget connect(Widget child) {
    return RelationsWebSocketManager._(child);
  }

  @override
  State<StatefulWidget> createState() => _RelationsWebSocketState();
}

class _RelationsWebSocketState extends State<RelationsWebSocketManager>
    with WidgetsBindingObserver, WidgetsBindingObserverRegistrar {
  final _relationsWebSocket = dependencyLocator<RelationsWebSocket>();
  final _eventBus = dependencyLocator<EventBusObserver>();

  void _registerEventListeners() {
    _eventBus
      ..on<UserLoggedIn>((_) => _relationsWebSocket.connect())
      ..on<UserWasLoggedOutEvent>((_) => _relationsWebSocket.disconnect());
  }

  @override
  void initState() {
    super.initState();
    _registerEventListeners();
    _relationsWebSocket.connect();
  }

  @override
  void dispose() {
    super.dispose();
    _relationsWebSocket.disconnect();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      _relationsWebSocket.connect();
    } else if (state == AppLifecycleState.paused) {
      _relationsWebSocket.disconnect();
    }
  }

  void _handleConnectivityChanges(
    BuildContext context,
    ConnectivityState state,
  ) {
    state.map(
      connected: (_) => _relationsWebSocket.connect(),
      disconnected: (_) => _relationsWebSocket.disconnect(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectivityCheckerCubit, ConnectivityState>(
      listener: _handleConnectivityChanges,
      child: widget.child,
    );
  }
}

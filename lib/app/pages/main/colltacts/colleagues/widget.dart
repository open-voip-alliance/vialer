import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vialer/dependency_locator.dart';
import 'package:vialer/domain/event/event_bus.dart';
import 'package:vialer/domain/relations/websocket/relations_websocket.dart';

import '../../../../../domain/authentication/user_logged_in.dart';
import '../../../../util/widgets_binding_observer_registrar.dart';
import '../../../../widgets/connectivity_checker/cubit.dart';

class ColleagueWebSocket extends StatefulWidget {
  const ColleagueWebSocket._(this.child);

  final Widget child;

  static Widget connect({
    required Widget child,
  }) =>
      ColleagueWebSocket._(child);

  @override
  State<StatefulWidget> createState() => _ColleagueWebSocketState();
}

class _ColleagueWebSocketState extends State<ColleagueWebSocket>
    with WidgetsBindingObserver, WidgetsBindingObserverRegistrar {
  final _websocket = dependencyLocator<RelationsWebsocket>();
  final _eventBus = dependencyLocator<EventBusObserver>();

  @override
  void initState() {
    super.initState();
    unawaited(_websocket.connect());
    _eventBus.on<UserLoggedIn>((_) => unawaited(_websocket.connect()));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      unawaited(_websocket.connect());
    }
  }

  void _handleConnectivityChanges(
    BuildContext context,
    ConnectivityState state,
  ) {
    unawaited(
      state.map(
        connected: (_) => _websocket.connect(),
        disconnected: (_) => _websocket.disconnect(),
      ),
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

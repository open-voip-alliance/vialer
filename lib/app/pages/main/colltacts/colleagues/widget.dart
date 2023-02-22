import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../util/widgets_binding_observer_registrar.dart';
import '../../../../widgets/connectivity_checker/cubit.dart';
import 'cubit.dart';

class ColleagueWebSocket extends StatefulWidget {
  final Widget child;

  ColleagueWebSocket._(this.child);

  static Widget connect({
    required Widget child,
  }) =>
      ColleagueWebSocket._(child);

  @override
  State<StatefulWidget> createState() => _ColleagueWebSocketState();
}

class _ColleagueWebSocketState extends State<ColleagueWebSocket>
    with WidgetsBindingObserver, WidgetsBindingObserverRegistrar {
  @override
  void initState() {
    super.initState();
    context.read<ColleagueCubit>().connectToWebSocket();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      context.read<ColleagueCubit>().connectToWebSocket();
    }
  }

  void _handleConnectivityChanges(
    BuildContext context,
    ConnectivityState state,
  ) {
    final cubit = context.read<ColleagueCubit>();

    state.map(
      connected: (_) => cubit.connectToWebSocket(),
      disconnected: (_) => cubit.disconnectFromWebSocket(),
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

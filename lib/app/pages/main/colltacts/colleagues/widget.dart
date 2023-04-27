import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../util/widgets_binding_observer_registrar.dart';
import '../../../../widgets/connectivity_checker/cubit.dart';
import 'cubit.dart';

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
  @override
  void initState() {
    super.initState();
    context.read<ColleaguesCubit>().connectToWebSocket();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      context.read<ColleaguesCubit>().connectToWebSocket();
    }
  }

  void _handleConnectivityChanges(
    BuildContext context,
    ConnectivityState state,
  ) {
    final cubit = context.read<ColleaguesCubit>();

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

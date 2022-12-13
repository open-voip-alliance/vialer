import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../util/widgets_binding_observer_registrar.dart';
import 'cubit.dart';

class ColleagueWebSocket extends StatefulWidget {
  final Widget child;

  ColleagueWebSocket._(this.child);

  static Widget connect({
    required Widget child,
  }) {
    return BlocProvider<ColleagueCubit>(
      create: (_) => ColleagueCubit(),
      child: ColleagueWebSocket._(child),
    );
  }

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
    } else if (state == AppLifecycleState.paused) {
      context.read<ColleagueCubit>().disconnectFromWebSocket();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

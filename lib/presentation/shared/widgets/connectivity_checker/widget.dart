import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../util/widgets_binding_observer_registrar.dart';
import '../../controllers/connectivity_checker/cubit.dart';

class ConnectivityChecker extends StatefulWidget {
  const ConnectivityChecker._(this.child);

  final Widget child;

  static Widget create({
    required Widget child,
  }) {
    return BlocProvider<ConnectivityCheckerCubit>(
      create: (_) => ConnectivityCheckerCubit(),
      child: ConnectivityChecker._(child),
    );
  }

  @override
  State<StatefulWidget> createState() => _ConnectivityCheckerState();
}

class _ConnectivityCheckerState extends State<ConnectivityChecker>
    with WidgetsBindingObserver, WidgetsBindingObserverRegistrar {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      unawaited(context.read<ConnectivityCheckerCubit>().check());
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../util/widgets_binding_observer_registrar.dart';
import 'cubit.dart';

class LogUploader extends StatefulWidget {
  final Widget child;

  LogUploader._(this.child);

  static Widget create({
    required Widget child,
  }) {
    return BlocProvider<LogUploaderCubit>(
      create: (_) => LogUploaderCubit(),
      child: LogUploader._(child),
    );
  }

  @override
  State<StatefulWidget> createState() => _LogUploaderState();
}

class _LogUploaderState extends State<LogUploader>
    with WidgetsBindingObserver, WidgetsBindingObserverRegistrar {

  @override
  void initState() {
    context.read<LogUploaderCubit>().upload();
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    context.read<LogUploaderCubit>().upload();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

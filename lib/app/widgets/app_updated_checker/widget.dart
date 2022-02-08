import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../resources/localizations.dart';
import '../../util/widgets_binding_observer_registrar.dart';
import 'cubit.dart';
import 'dialog.dart';

class AppUpdatedChecker extends StatefulWidget {
  final Widget child;

  AppUpdatedChecker({required this.child});

  @override
  State<StatefulWidget> createState() => _AppUpdatedCheckerState();
}

class _AppUpdatedCheckerState extends State<AppUpdatedChecker>
    with WidgetsBindingObserver, WidgetsBindingObserverRegistrar {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      context.read<AppUpdatedCheckerCubit>().check();
    }
  }

  void _onStateChanged(BuildContext context, AppUpdatedState state) {
    if (state is NewUpdateWasInstalled) {
      showDialog<void>(
        context: context,
        builder: (context) {
          return ReleaseNotesDialog(
            releaseNotes: context.msg.releaseNotes,
            version: state.version,
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppUpdatedCheckerCubit>(
      create: (_) => AppUpdatedCheckerCubit(),
      child: BlocListener<AppUpdatedCheckerCubit, AppUpdatedState>(
        listener: _onStateChanged,
        child: widget.child,
      ),
    );
  }
}

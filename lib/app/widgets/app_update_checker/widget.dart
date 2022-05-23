import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../pages/main/widgets/caller/cubit.dart';
import '../../resources/localizations.dart';
import '../../util/conditional_capitalization.dart';
import '../../util/widgets_binding_observer_registrar.dart';
import 'cubit.dart';
import 'release_notes_dialog.dart';

class AppUpdateChecker extends StatefulWidget {
  final Widget child;

  AppUpdateChecker._(this.child);

  static Widget create({
    required Widget child,
  }) {
    return BlocProvider<AppUpdateCheckerCubit>(
      create: (context) => AppUpdateCheckerCubit(context.read<CallerCubit>()),
      child: AppUpdateChecker._(child),
    );
  }

  @override
  State<StatefulWidget> createState() => _AppUpdateCheckerState();
}

class _AppUpdateCheckerState extends State<AppUpdateChecker>
    with WidgetsBindingObserver, WidgetsBindingObserverRegistrar {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      context.read<AppUpdateCheckerCubit>().check();
    }
  }

  void _onStateChanged(BuildContext context, AppUpdateState state) {
    final cubit = context.read<AppUpdateCheckerCubit>();

    if (state is NewUpdateWasInstalled) {
      showDialog(
        context: context,
        builder: (context) {
          return ReleaseNotesDialog(
            releaseNotes: context.msg.main.update.releaseNotes.notes,
            version: state.version,
          );
        },
      );
    } else if (state is UpdateReadyToInstall) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(context.msg.main.update.readyToInstall.title),
            content: Text(context.msg.main.update.readyToInstall.content),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  context.msg.main.update.readyToInstall.actions.notNow
                      .toUpperCaseIfAndroid(context),
                ),
              ),
              TextButton(
                onPressed: cubit.completeFlexibleUpdate,
                child: Text(
                  context.msg.main.update.readyToInstall.actions.install
                      .toUpperCaseIfAndroid(context),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppUpdateCheckerCubit, AppUpdateState>(
      listener: _onStateChanged,
      child: widget.child,
    );
  }
}

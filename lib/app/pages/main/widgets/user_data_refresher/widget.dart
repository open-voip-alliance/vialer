import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../util/widgets_binding_observer_registrar.dart';

import 'cubit.dart';

class UserDataRefresher extends StatelessWidget {
  final Widget child;

  const UserDataRefresher({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserDataRefresherCubit>(
      lazy: false,
      create: (_) => UserDataRefresherCubit(),
      child: _UserDataRefresher(child),
    );
  }
}

/// Private widget with a context that has access to [UserDataRefresherCubit].
class _UserDataRefresher extends StatefulWidget {
  final Widget child;

  _UserDataRefresher(this.child);

  @override
  _UserDataRefresherState createState() => _UserDataRefresherState();
}

class _UserDataRefresherState extends State<_UserDataRefresher>
    with WidgetsBindingObserver, WidgetsBindingObserverRegistrar {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cubit = context.read<UserDataRefresherCubit>();

    if (state == AppLifecycleState.resumed) {
      cubit.refresh();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

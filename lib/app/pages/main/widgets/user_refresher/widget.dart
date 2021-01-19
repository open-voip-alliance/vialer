import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit.dart';

class UserRefresher extends StatelessWidget {
  final Widget child;

  const UserRefresher({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserRefresherCubit>(
      create: (_) => UserRefresherCubit(),
      lazy: false,
      child: _UserChecker(child),
    );
  }
}

/// Private widget with a context that has access to [UserRefresherCubit].
class _UserChecker extends StatefulWidget {
  final Widget child;

  _UserChecker(this.child);

  @override
  _UserCheckerState createState() => _UserCheckerState();
}

class _UserCheckerState extends State<_UserChecker>
    with
        // ignore: prefer_mixin
        WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cubit = context.read<UserRefresherCubit>();

    if (state == AppLifecycleState.resumed) {
      cubit.refresh();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void dispose() {
    super.dispose();

    WidgetsBinding.instance.removeObserver(this);
  }
}

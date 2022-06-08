import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../routes.dart';
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

  const _UserDataRefresher(this.child);

  @override
  _UserDataRefresherState createState() => _UserDataRefresherState();
}

class _UserDataRefresherState extends State<_UserDataRefresher>
    with WidgetsBindingObserver, WidgetsBindingObserverRegistrar {
  UserDataRefresherCubit get cubit => context.read<UserDataRefresherCubit>();

  Timer? _refreshTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      cubit.refresh();

      _refreshTimer ??= Timer.periodic(const Duration(seconds: 30), (_) {
        cubit.refresh();
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    final cubit = context.read<UserDataRefresherCubit>();

    if (cubit.state is! LoggedOut && state == AppLifecycleState.resumed) {
      cubit.refresh();
    }
  }

  void _onStateChanged(BuildContext context, UserDataRefresherState state) {
    if (state is LoggedOut) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.onboarding,
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) =>
      BlocListener<UserDataRefresherCubit, UserDataRefresherState>(
        listener: _onStateChanged,
        child: widget.child,
      );

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}

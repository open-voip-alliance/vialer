import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vialer/data/models/user/refresh/user_refresh_task.dart';

import '../../../util/widgets_binding_observer_registrar.dart';
import '../../controllers/user_data_refresher/cubit.dart';

class UserDataRefresher extends StatelessWidget {
  const UserDataRefresher({required this.child, super.key});

  final Widget child;

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
  const _UserDataRefresher(this.child);

  final Widget child;

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
      unawaited(cubit.refreshIfReady(UserRefreshTask.minimal));

      _refreshTimer ??= Timer.periodic(const Duration(seconds: 10), (_) {
        unawaited(cubit.refreshIfReady(UserRefreshTask.minimal));
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      unawaited(
        context
            .read<UserDataRefresherCubit>()
            .refreshIfReady(UserRefreshTask.all),
      );
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}

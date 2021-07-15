import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit.dart';

class MissedCallNotificationPressedListener extends StatelessWidget {
  final VoidCallback onMissedCallNotificationPressed;
  final Widget? child;

  const MissedCallNotificationPressedListener({
    Key? key,
    required this.onMissedCallNotificationPressed,
    this.child,
  }) : super(key: key);

  void _onStateChanged(
    BuildContext context,
    MissedCallNotificationPressedListenerState state,
  ) {
    if (state is MissedCallNotificationPressed) {
      onMissedCallNotificationPressed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MissedCallNotificationPressedListenerCubit>(
      create: (_) => MissedCallNotificationPressedListenerCubit(),
      child: BlocListener<MissedCallNotificationPressedListenerCubit,
          MissedCallNotificationPressedListenerState>(
        listener: _onStateChanged,
        child: child,
      ),
    );
  }
}

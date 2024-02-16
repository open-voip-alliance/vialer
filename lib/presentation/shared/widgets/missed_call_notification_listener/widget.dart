import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../controllers/missed_call_notification_listener/cubit.dart';

class MissedCallNotificationPressedListener extends StatelessWidget {
  const MissedCallNotificationPressedListener({
    required this.onMissedCallNotificationPressed,
    this.child,
    super.key,
  });

  final VoidCallback onMissedCallNotificationPressed;
  final Widget? child;

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

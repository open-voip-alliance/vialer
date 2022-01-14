import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../widgets/caller/cubit.dart';

/// Only builds when the [CallerCubit]'s state is a [CallProcessState].
class CallProcessStateBuilder extends StatelessWidget {
  final BlocWidgetBuilder<CallProcessState> builder;

  const CallProcessStateBuilder({
    required this.builder,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CallerCubit, CallerState>(
      buildWhen: (_, current) => current is CallProcessState,
      builder: (context, state) => builder(context, state as CallProcessState),
    );
  }
}

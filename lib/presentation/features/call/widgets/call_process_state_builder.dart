import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vialer/presentation/util/loggable.dart';

import '../../../shared/controllers/caller/cubit.dart';

/// Only builds when the [CallerCubit]'s state is a [CallProcessState].
class CallProcessStateBuilder extends StatelessWidget with Loggable {
  CallProcessStateBuilder({
    required this.builder,
    super.key,
  });

  final BlocWidgetBuilder<CallProcessState> builder;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CallerCubit, CallerState>(
      buildWhen: (_, current) {
        if (current is! CallProcessState) return false;

        if (current.voipCall == null) {
          logger.warning(
            'State is ${current.runtimeType}(CallProcessState) but no active '
            'voip call',
          );
          return false;
        }

        return true;
      },
      builder: (context, state) => builder(context, state as CallProcessState),
    );
  }
}

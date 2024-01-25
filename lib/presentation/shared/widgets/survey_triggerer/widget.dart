import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../features/survey/widgets/dialog.dart';
import '../../controllers/survey_triggerer/cubit.dart';
import '../caller.dart';

class SurveyTriggerer extends StatelessWidget {
  const SurveyTriggerer({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SurveyTriggererCubit>(
      lazy: false,
      create: (_) => SurveyTriggererCubit(context.read<CallerCubit>()),
      child: _SurveyTriggerer(child),
    );
  }
}

/// Private widget with a context that has access to [SurveyTriggererCubit].
class _SurveyTriggerer extends StatefulWidget {
  const _SurveyTriggerer(this.child);

  final Widget child;

  @override
  _SurveyTriggererState createState() => _SurveyTriggererState();
}

class _SurveyTriggererState extends State<_SurveyTriggerer> {
  SurveyTriggererCubit get cubit => context.read<SurveyTriggererCubit>();

  bool _checked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_checked) {
      _checked = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(cubit.check());
      });
    }
  }

  void _onStateChanged(BuildContext context, SurveyTriggererState state) {
    if (state is SurveyTriggered) {
      unawaited(SurveyDialog.show(context, state.id, trigger: state.trigger));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SurveyTriggererCubit, SurveyTriggererState>(
      listener: _onStateChanged,
      child: widget.child,
    );
  }
}

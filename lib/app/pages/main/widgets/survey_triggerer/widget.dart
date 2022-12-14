import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../survey/dialog.dart';
import '../caller.dart';
import 'cubit.dart';

class SurveyTriggerer extends StatelessWidget {
  final Widget child;

  const SurveyTriggerer({Key? key, required this.child}) : super(key: key);

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
  final Widget child;

  const _SurveyTriggerer(this.child);

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
        cubit.check();
      });
    }
  }

  void _onStateChanged(BuildContext context, SurveyTriggererState state) {
    if (state is SurveyTriggered) {
      SurveyDialog.show(context, state.id, trigger: state.trigger);
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

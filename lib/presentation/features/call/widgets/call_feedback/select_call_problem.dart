import 'package:flutter/material.dart';
import 'package:vialer/presentation/resources/localizations.dart';
import 'package:vialer/presentation/resources/theme.dart';

import '../../../../../../data/models/feedback/call_problem.dart';
import 'call_feedback.dart';

class SelectCallProblem extends StatelessWidget {
  const SelectCallProblem({
    required this.onComplete,
    super.key,
  });

  List<CallProblem> get _types => CallProblem.values;
  final void Function(CallProblem type) onComplete;

  @override
  Widget build(BuildContext context) {
    return CallFeedbackAlertDialog(
      title: context.msg.main.call.feedback.problem.title,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ..._types.map(
            (problem) => _CallProblemButton(
              problem: problem,
              onPressed: () => onComplete(problem),
            ),
          ),
        ],
      ),
    );
  }
}

class _CallProblemButton extends StatelessWidget {
  const _CallProblemButton({
    required this.problem,
    required this.onPressed,
  });

  final CallProblem problem;
  final VoidCallback onPressed;

  String _text(BuildContext context) {
    final strings = context.msg.main.call.feedback.problem;

    return switch (problem) {
      CallProblem.oneWayAudio => strings.oneWayAudio,
      CallProblem.noAudio => strings.noAudio,
      CallProblem.audioProblem => strings.audioProblem,
      CallProblem.endedUnexpectedly => strings.endedUnexpectedly,
      CallProblem.somethingElse => strings.somethingElse
    };
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: BorderSide(
          width: 1,
          color: context.brand.theme.colors.primary.withOpacity(0.12),
        ),
      ),
      child: FittedBox(
        fit: BoxFit.fitWidth,
        child: Text(
          _text(context),
          textAlign: TextAlign.start,
          style: TextStyle(
            color: context.brand.theme.colors.grey6,
          ),
        ),
      ),
    );
  }
}

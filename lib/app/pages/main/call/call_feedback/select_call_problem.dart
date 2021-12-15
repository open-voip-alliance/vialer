import 'package:flutter/material.dart';

import '../../../../../domain/entities/call_problem.dart';
import '../../../../resources/localizations.dart';
import '../../../../util/brand.dart';
import 'call_feedback.dart';

class SelectCallProblem extends StatelessWidget {
  final _types = CallProblem.values;
  final Function(CallProblem type) onComplete;

  const SelectCallProblem({
    required this.onComplete,
  });

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
  final CallProblem problem;
  final VoidCallback onPressed;

  const _CallProblemButton({
    required this.problem,
    required this.onPressed,
  });

  String _text(BuildContext context) {
    final strings = context.msg.main.call.feedback.problem;

    switch (problem) {
      case CallProblem.oneWayAudio:
        return strings.oneWayAudio;
      case CallProblem.noAudio:
        return strings.noAudio;
      case CallProblem.audioProblem:
        return strings.audioProblem;
      case CallProblem.endedUnexpectedly:
        return strings.endedUnexpectedly;
      case CallProblem.somethingElse:
        return strings.somethingElse;
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: FittedBox(
        fit: BoxFit.fitWidth,
        child: Text(
          _text(context),
          textAlign: TextAlign.start,
          style: TextStyle(
            color: context.brand.theme.grey6,
          ),
        ),
      ),
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
      ),
    );
  }
}

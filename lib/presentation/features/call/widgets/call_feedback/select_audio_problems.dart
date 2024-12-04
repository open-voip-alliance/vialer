import 'package:flutter/material.dart';
import 'package:vialer/presentation/resources/localizations.dart';

import '../../../../../../data/models/feedback/call_problem.dart';
import '../../../../../../domain/usecases/calling/voip/rate_voip_call.dart';
import 'call_feedback.dart';

class SelectAudioProblems extends StatefulWidget {
  const SelectAudioProblems({required this.onComplete, super.key});

  final void Function(List<CallAudioProblem> audioProblems) onComplete;

  @override
  State<StatefulWidget> createState() => _SelectAudioProblemsState();
}

class _SelectAudioProblemsState extends State<SelectAudioProblems> {
  final selection = CallAudioProblem.values.toBoolMap();

  String _text(CallAudioProblem audioProblem) => switch (audioProblem) {
        CallAudioProblem.jitter =>
          context.msg.main.call.feedback.audioProblems.jitter,
        CallAudioProblem.echo =>
          context.msg.main.call.feedback.audioProblems.echo,
        CallAudioProblem.crackling =>
          context.msg.main.call.feedback.audioProblems.crackling,
        CallAudioProblem.robotic =>
          context.msg.main.call.feedback.audioProblems.robotic,
        CallAudioProblem.tooQuiet =>
          context.msg.main.call.feedback.audioProblems.tooQuiet,
        CallAudioProblem.tooLoud =>
          context.msg.main.call.feedback.audioProblems.tooLoud
      };

  void _onDonePressed() {
    final audioProblems =
        selection.entries.where((e) => e.value).map((e) => e.key).toList();

    widget.onComplete(audioProblems);
  }

  @override
  Widget build(BuildContext context) {
    return CallFeedbackAlertDialog(
      title: context.msg.main.call.feedback.audioProblems.title,
      actions: [
        TextButton(
          onPressed: _onDonePressed,
          child: Text(
            context.msg.main.call.feedback.audioProblems.done.toUpperCase(),
          ),
        ),
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...selection.entries.map(
            (entry) => CheckboxListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
              ).copyWith(
                left: 0,
              ),
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,
              title: FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Text(
                  _text(entry.key),
                  textAlign: TextAlign.left,
                ),
              ),
              value: selection[entry.key],
              onChanged: (changed) => setState(
                () => selection[entry.key] = changed ?? false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

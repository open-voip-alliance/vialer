import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../../../domain/entities/call_problem.dart';
import '../../../../../domain/usecases/call/voip/rate_voip_call.dart';
import '../../../../resources/localizations.dart';
import '../../../../util/brand.dart';
import 'call_feedback.dart';

class SelectAudioProblems extends StatefulWidget {
  final Function(List<CallAudioProblem> audioProblems) onComplete;

  const SelectAudioProblems({required this.onComplete});

  @override
  State<StatefulWidget> createState() => _SelectAudioProblemsState();
}

class _SelectAudioProblemsState extends State<SelectAudioProblems> {
  final selection = CallAudioProblem.values.toBoolMap(
    defaultValue: false,
  );

  String _text(CallAudioProblem audioProblem) {
    switch (audioProblem) {
      case CallAudioProblem.jitter:
        return context.msg.main.call.feedback.audioProblems.jitter;
      case CallAudioProblem.echo:
        return context.msg.main.call.feedback.audioProblems.echo;
      case CallAudioProblem.crackling:
        return context.msg.main.call.feedback.audioProblems.crackling;
      case CallAudioProblem.robotic:
        return context.msg.main.call.feedback.audioProblems.robotic;
      case CallAudioProblem.tooQuiet:
        return context.msg.main.call.feedback.audioProblems.tooQuiet;
      case CallAudioProblem.tooLoud:
        return context.msg.main.call.feedback.audioProblems.tooLoud;
    }
  }

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
          style: TextButton.styleFrom(
            primary: context.brand.theme.buttonColoredRaisedTextColor,
          ),
        )
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...selection.entries.map(
            (entry) => CheckboxListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 0,
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

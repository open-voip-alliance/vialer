import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:vialer/presentation/util/context_extensions.dart';

/// Handles rendering a list of options, of which the user can only select one.
/// These are presented to the user as radio buttons.
class RadioButtonSurveyQuestion<T> extends StatefulWidget {
  const RadioButtonSurveyQuestion({
    super.key,
    required this.answer,
    required this.answers,
  });

  /// A map between the key and a possible answer.
  final Map<T, String> answers;

  /// A [ValueNotifier] so you can listen for changes to the currently selected
  /// answer.
  final ValueNotifier<T?> answer;

  @override
  State<RadioButtonSurveyQuestion<T>> createState() =>
      _RadioButtonSurveyQuestionState<T>();
}

class _RadioButtonSurveyQuestionState<T>
    extends State<RadioButtonSurveyQuestion<T>> {
  void _onAnswerChanged(T? answer) => widget.answer.value = answer;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.answer,
      builder: (_, __, ___) {
        return Column(
          children: widget.answers.entries.map(
            (entry) {
              return Column(
                children: [
                  ListTile(
                    onTap: () => _onAnswerChanged(entry.key),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: context.colors.grey1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.only(right: 8),
                    dense: true,
                    title: Text(
                      entry.value,
                      style: TextStyle(fontSize: 14),
                    ),
                    horizontalTitleGap: 0,
                    leading: Radio<T>(
                      activeColor: context.colors.primary,
                      value: entry.key,
                      groupValue: widget.answer.value,
                      onChanged: _onAnswerChanged,
                    ),
                  ),
                  Gap(8),
                ],
              );
            },
          ).toList(),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:vialer/presentation/features/messaging_survey/messaging_survey_page.dart';
import 'package:vialer/presentation/resources/localizations.dart';
import 'package:vialer/presentation/resources/theme.dart';

/// An action in the [MessagingSurvey], the text that is show depends on the
/// provided [MessagingSurveyButtonType].
class MessagingSurveyButton extends StatelessWidget {
  const MessagingSurveyButton(
    this.type, {
    required this.onPressed,
  });

  final MessagingSurveyButtonType type;
  final VoidCallback? onPressed;

  String _text(BuildContext context) => switch (type) {
        MessagingSurveyButtonType.skip => context.strings.button.skip,
        MessagingSurveyButtonType.yesContinue =>
          context.strings.button.yesContinue,
        MessagingSurveyButtonType.next => context.msg.generic.button.next,
        MessagingSurveyButtonType.finish => context.strings.button.finish,
        MessagingSurveyButtonType.close => context.msg.generic.button.close,
      };

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: context.brand.theme.colors.primary,
        disabledForegroundColor: context.brand.theme.colors.grey4,
      ),
      child: Text(_text(context)),
    );
  }
}

enum MessagingSurveyButtonType {
  skip,
  yesContinue,
  next,
  finish,
  close,
}

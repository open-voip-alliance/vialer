import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/presentation/features/messaging_survey/survey/questions/installed_messaging_apps_survey_question.dart';

import '../../widgets/messaging_survey_button.dart';
import '../messaging_survey.dart';
import '../../messaging_survey_page.dart';
import '../../widgets/messaging_survey_scaffold.dart';
import '../../widgets/multiple_choice_survey_question.dart';

class JoinResearchPoolSurveyQuestion extends ConsumerStatefulWidget {
  const JoinResearchPoolSurveyQuestion(
    this.onQuestionAnswered, {
    super.key,
  });

  final OnQuestionAnswered onQuestionAnswered;

  @override
  ConsumerState<JoinResearchPoolSurveyQuestion> createState() =>
      _JoinResearchPoolSurveyQuestionState();
}

class _JoinResearchPoolSurveyQuestionState
    extends ConsumerState<JoinResearchPoolSurveyQuestion> {
  final _answer = ValueNotifier<int?>(null);

  void _onQuestionAnswered() => widget.onQuestionAnswered(
        ref.response.copyWith(joinResearchPool: _answer.value == 0),
      );

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _answer,
      builder: (_, answer, ___) {
        return MessagingSurveyQuestionScaffold(
          icon: FontAwesomeIcons.solidCircleUser,
          title: context.strings.joinResearchPool.title,
          subtitle: context.strings.joinResearchPool.description,
          actions: [
            MessagingSurveyButton(
              MessagingSurveyButtonType.finish,
              onPressed: answer != null ? _onQuestionAnswered : null,
            ),
          ],
          child: RadioButtonSurveyQuestion(
            answer: _answer,
            answers: {
              0: context.strings.joinResearchPool.yes,
              1: context.strings.joinResearchPool.no,
            },
          ),
        );
      },
    );
  }
}

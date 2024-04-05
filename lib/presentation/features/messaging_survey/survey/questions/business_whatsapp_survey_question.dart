import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/presentation/features/messaging_survey/survey/questions/installed_messaging_apps_survey_question.dart';
import 'package:vialer/presentation/features/messaging_survey/widgets/messaging_survey_button.dart';

import '../messaging_survey.dart';
import '../../messaging_survey_page.dart';
import '../../widgets/messaging_survey_scaffold.dart';
import '../../widgets/multiple_choice_survey_question.dart';

class BusinessWhatsappSurveyQuestion extends ConsumerStatefulWidget {
  const BusinessWhatsappSurveyQuestion(
    this.onQuestionAnswered, {
    super.key,
  });

  final OnQuestionAnswered onQuestionAnswered;

  @override
  ConsumerState<BusinessWhatsappSurveyQuestion> createState() =>
      _BusinessWhatsappSurveyQuestionState();
}

class _BusinessWhatsappSurveyQuestionState
    extends ConsumerState<BusinessWhatsappSurveyQuestion> {
  final _answer = ValueNotifier<int?>(null);

  void _onQuestionAnswered() => widget.onQuestionAnswered(
        ref.response.copyWith(questionBusinessWhatsapp: _answer.value),
      );

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _answer,
      builder: (_, answer, ___) {
        return MessagingSurveyQuestionScaffold(
          icon: FontAwesomeIcons.whatsapp,
          title: context.strings.messagingApps.businessWhatsApp.title,
          subtitle: context.strings.messagingApps.businessWhatsApp.description,
          actions: [
            MessagingSurveyButton(
              MessagingSurveyButtonType.next,
              onPressed: answer != null ? _onQuestionAnswered : null,
            ),
          ],
          child: RadioButtonSurveyQuestion(
            answer: _answer,
            answers: {
              0: context.strings.messagingApps.businessWhatsApp.option1,
              1: context.strings.messagingApps.businessWhatsApp.option2,
              2: context.strings.messagingApps.businessWhatsApp.option3,
              3: context.strings.messagingApps.businessWhatsApp.option4,
              4: context.strings.messagingApps.businessWhatsApp.option5,
            },
          ),
        );
      },
    );
  }
}

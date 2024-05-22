import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/presentation/features/messaging_survey/messaging_survey_page.dart';
import 'package:vialer/presentation/features/messaging_survey/widgets/messaging_survey_button.dart';
import '../../widgets/messaging_survey_scaffold.dart';

class MessagingSurveyComplete extends StatelessWidget {
  const MessagingSurveyComplete({super.key, required this.didJoinResearchPool});

  final bool didJoinResearchPool;

  @override
  Widget build(BuildContext context) {
    return MessagingSurveyQuestionScaffold(
      icon: FontAwesomeIcons.partyHorn,
      title: didJoinResearchPool
          ? context.strings.finished.joinedCommunity.title
          : context.strings.finished.title,
      subtitle: didJoinResearchPool
          ? context.strings.finished.joinedCommunity.description
          : context.strings.finished.description,
      actions: [
        MessagingSurveyButton(
          MessagingSurveyButtonType.close,
          onPressed: Navigator.of(context).pop,
        ),
      ],
      child: Container(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/feedback/survey/survey.dart';
import '../../../../domain/feedback/survey/survey_trigger.dart';
import 'cubit.dart';
import 'screen/help_us.dart';
import 'screen/question.dart';
import 'screen/thank_you.dart';

class SurveyDialog extends StatelessWidget {
  final SurveyId surveyId;
  final SurveyTrigger trigger;

  static Future<void> show(
    BuildContext context,
    SurveyId surveyId, {
    required SurveyTrigger trigger,
  }) async {
    await showDialog(
      context: context,
      builder: (context) {
        return SurveyDialog._(surveyId: surveyId, trigger: trigger);
      },
    );
  }

  SurveyDialog._({
    Key? key,
    required this.surveyId,
    required this.trigger,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: BlocProvider<SurveyCubit>(
        create: (_) => SurveyCubit(
          id: surveyId,
          language: Localizations.localeOf(context).languageCode,
          trigger: trigger,
        ),
        child: BlocBuilder<SurveyCubit, SurveyState>(
          builder: (context, state) {
            if (state is ShowHelpUsPrompt) {
              return HelpUsScreen(
                dontShowThisAgain: state.dontShowThisAgain,
              );
            } else if (state is ShowQuestion) {
              return QuestionScreen(
                key: ValueKey(state.question),
                question: state.question,
                survey: state.survey!,
                answer: state.answer,
              );
            } else if (state is ShowThankYou) {
              return const ThankYouScreen();
            } else if (state is LoadingSurvey) {
              return const SizedBox();
            } else {
              throw UnsupportedError('Unsupported state: $state');
            }
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../data/models/feedback/survey/survey.dart';
import '../../../../../data/models/feedback/survey/survey_trigger.dart';
import '../controllers/cubit.dart';
import 'screens/help_us.dart';
import 'screens/question.dart';
import 'screens/thank_you.dart';

class SurveyDialog extends StatelessWidget {
  const SurveyDialog._({
    required this.surveyId,
    required this.trigger,
  });

  final SurveyId surveyId;
  final SurveyTrigger trigger;

  static Future<void> show(
    BuildContext context,
    SurveyId surveyId, {
    required SurveyTrigger trigger,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return SurveyDialog._(surveyId: surveyId, trigger: trigger);
      },
    );
  }

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

import 'dart:async';

import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vialer/data/models/messaging_survey/messaging_survey_response.dart';
import 'package:vialer/presentation/features/messaging_survey/controllers/riverpod.dart';
import 'package:vialer/presentation/features/messaging_survey/survey/questions/business_whatsapp_survey_question.dart';
import 'package:vialer/presentation/features/messaging_survey/survey/questions/installed_messaging_apps_survey_question.dart';
import 'package:vialer/presentation/features/messaging_survey/survey/questions/join_research_pool_survey_question.dart';
import 'package:vialer/presentation/features/messaging_survey/survey/questions/personal_whatsapp_survey_question.dart';
import 'package:vialer/presentation/features/messaging_survey/survey/questions/thank_you.dart';

/// Provide the updated [MessagingSurveyResponse] object.
/// Expects a [FutureOr] so the user does not need to wait when we need to
/// fetch data async, the survey will continue and the data will be updated
/// in the background.
typedef OnQuestionAnswered = void Function(FutureOr<MessagingSurveyResponse>);

class MessagingSurvey extends ConsumerStatefulWidget {
  const MessagingSurvey({super.key});

  @override
  ConsumerState<MessagingSurvey> createState() => _MessagingSurveyState();
}

class _MessagingSurveyState extends ConsumerState<MessagingSurvey> {
  final _controller = PageController();

  bool get _hasAnsweredAllQuestions =>
      (_controller.page ?? _controller.initialPage) >= (_questions.length - 1);

  late final _questions = [
    InstalledMessagingAppsSurveyQuestion(onQuestionAnswered),
    PersonalWhatsappSurveyQuestion(onQuestionAnswered),
    BusinessWhatsappSurveyQuestion(onQuestionAnswered),
    JoinResearchPoolSurveyQuestion(onQuestionAnswered),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ExpandablePageView(
        // Prevents the user from being able to manually swipe through the screens
        physics: NeverScrollableScrollPhysics(),
        controller: _controller,
        children: [
          ..._questions,
          MessagingSurveyComplete(),
        ],
      ),
    );
  }

  void onQuestionAnswered(FutureOr<MessagingSurveyResponse> response) async {
    final controller = ref.read(messagingSurveyControllerProvider.notifier);

    _controller.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );

    controller.response = await response;

    if (_hasAnsweredAllQuestions) {
      controller.submit();
    }
  }
}

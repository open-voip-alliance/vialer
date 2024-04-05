import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/data/models/messaging_survey/messaging_survey_response.dart';
import 'package:vialer/domain/usecases/messaging_survey/get_installed_messaging_apps.dart';
import 'package:vialer/presentation/features/messaging_survey/controllers/riverpod.dart';
import '../../widgets/messaging_survey_button.dart';
import '../../widgets/messaging_survey_scaffold.dart';

import '../messaging_survey.dart';
import '../../messaging_survey_page.dart';

class InstalledMessagingAppsSurveyQuestion extends ConsumerWidget {
  const InstalledMessagingAppsSurveyQuestion(
    this.onQuestionResult, {
    super.key,
  });

  final OnQuestionAnswered onQuestionResult;

  void _onConsent(MessagingSurveyResponse response) async => onQuestionResult(
        response.copyWith(
          installedApps: await GetInstalledMessagingApps()(),
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MessagingSurveyQuestionScaffold(
      icon: FontAwesomeIcons.magnifyingGlass,
      title: context.strings.messagingApps.appInsights.title,
      subtitle: context.strings.messagingApps.appInsights.description,
      child: Container(),
      actions: [
        MessagingSurveyButton(
          MessagingSurveyButtonType.skip,
          onPressed: () => onQuestionResult(ref.response),
        ),
        MessagingSurveyButton(
          MessagingSurveyButtonType.yesContinue,
          onPressed: () => _onConsent(ref.response),
        ),
      ],
    );
  }
}

extension MessagingSurveyResponseWidgetRef on WidgetRef {
  MessagingSurveyResponse get response =>
      read(messagingSurveyControllerProvider.notifier).response;
}

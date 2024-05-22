import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:vialer/domain/usecases/user/get_logged_in_user.dart';
import 'package:vialer/presentation/features/messaging_survey/controllers/riverpod.dart';
import 'package:vialer/presentation/features/messaging_survey/survey/messaging_survey.dart';
import 'package:vialer/presentation/resources/localizations.dart';
import 'package:vialer/presentation/resources/messages.i18n.dart';
import 'package:vialer/presentation/resources/theme.dart';
import 'package:vialer/presentation/shared/widgets/stylized_button.dart';
import 'package:vialer/presentation/util/circular_graphic.dart';
import 'package:vialer/presentation/util/conditional_capitalization.dart';

class MessagingSurveyPage extends ConsumerWidget {
  const MessagingSurveyPage({super.key});

  String get _name => GetLoggedInUserUseCase()().fullName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularGraphic(FontAwesomeIcons.comments),
              Gap(40),
              Text(
                context.strings.messagingApps.intro(_name),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              Gap(48),
              StylizedButton.raised(
                child: Text(
                  context.strings.button.participate
                      .toUpperCaseIfAndroid(context),
                ),
                colored: true,
                onPressed: () => _launchSurvey(context),
              ),
              Gap(16),
              StylizedButton.outline(
                child: Text(
                  context.strings.button.notInterested.toUpperCaseIfAndroid(
                    context,
                  ),
                ),
                colored: true,
                onPressed: () => ref
                    .read(messagingSurveyControllerProvider.notifier)
                    .skipSurvey(),
              ),
              Gap(10),
              Text(
                context.strings.messagingApps.disclaimer,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.brand.theme.colors.grey5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchSurvey(BuildContext context) => showDialog<void>(
        context: context,
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Dialog(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: MessagingSurvey(),
                ),
              ),
            )
          ],
        ),
      );
}

extension SurveyStrings on BuildContext {
  SurveyMainMessages get strings => msg.main.survey;
}

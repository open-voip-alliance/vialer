import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:vialer/domain/usecases/user/get_logged_in_user.dart';
import 'package:vialer/presentation/features/messaging_survey/survey/messaging_survey.dart';
import 'package:vialer/presentation/resources/localizations.dart';
import 'package:vialer/presentation/resources/messages.i18n.dart';
import 'package:vialer/presentation/shared/widgets/stylized_button.dart';
import 'package:vialer/presentation/util/circular_graphic.dart';
import 'package:vialer/presentation/util/conditional_capitalization.dart';

class MessagingSurveyPage extends StatelessWidget {
  const MessagingSurveyPage({super.key});

  String get _name => GetLoggedInUserUseCase()().fullName;

  @override
  Widget build(BuildContext context) {
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
                onPressed: () => showDialog<void>(
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension SurveyStrings on BuildContext {
  SurveyMainMessages get strings => msg.main.survey;
}

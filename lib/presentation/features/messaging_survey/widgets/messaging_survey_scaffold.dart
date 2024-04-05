import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:vialer/presentation/features/messaging_survey/widgets/messaging_survey_button.dart';
import 'package:vialer/presentation/resources/theme.dart';

/// Provides the basic layout for a screen in the [MessagingSurvey].
class MessagingSurveyQuestionScaffold extends StatelessWidget {
  const MessagingSurveyQuestionScaffold({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actions = const [],
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  /// A list of [MessagingSurveyButton] that will be rendered at the bottom
  /// of the window.
  final List<MessagingSurveyButton> actions;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            children: [
              FaIcon(
                icon,
                size: 28,
                color: context.brand.theme.colors.primary,
              ),
              Gap(8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Gap(8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Gap(8),
        child,
        Gap(8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: actions,
        ),
      ],
    );
  }
}

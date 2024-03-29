import 'package:flutter/material.dart';
import 'package:vialer/presentation/resources/localizations.dart';
import 'package:vialer/presentation/util/conditional_capitalization.dart';

import '../big_header.dart';

class ThankYouScreen extends StatelessWidget {
  const ThankYouScreen({super.key});

  void _dismiss(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BigHeader(
          icon: Image.asset('assets/survey/yay.png'),
          text: Text(context.msg.main.survey.thankYou.title),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  context.msg.main.survey.thankYou.content,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 6),
                child: TextButton(
                  onPressed: () => _dismiss(context),
                  child: Text(
                    context.msg.generic.button.close
                        .toUpperCaseIfAndroid(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

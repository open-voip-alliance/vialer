import 'package:flutter/material.dart';

import '../../../resources/localizations.dart';
import '../../../util/conditional_capitalization.dart';
import '../../../widgets/stylized_button.dart';

class InfoPage extends StatelessWidget {
  final Widget icon;
  final Widget title;
  final Widget description;
  final VoidCallback onPressed;

  InfoPage({
    Key key,
    @required this.icon,
    @required this.title,
    @required this.description,
    @required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 48,
      ).copyWith(
        bottom: 24,
      ),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 64),
          IconTheme(
            data: IconTheme.of(context).copyWith(size: 54),
            child: icon,
          ),
          const SizedBox(height: 24),
          DefaultTextStyle(
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            child: title,
          ),
          const SizedBox(height: 24),
          DefaultTextStyle(
            style: const TextStyle(
              fontSize: 18,
            ),
            child: description,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                StylizedButton.raised(
                  onPressed: onPressed,
                  child: Text(
                    context.msg.onboarding.permission.button.iUnderstand
                        .toUpperCaseIfAndroid(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

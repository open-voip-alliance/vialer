import 'package:flutter/material.dart';

import '../../../resources/localizations.dart';
import '../widgets/stylized_button.dart';

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
      padding: EdgeInsets.symmetric(
        horizontal: 48,
      ).copyWith(
        bottom: 24,
      ),
      child: Column(
        children: <Widget>[
          SizedBox(height: 64),
          IconTheme(
            data: IconTheme.of(context).copyWith(size: 54),
            child: icon,
          ),
          SizedBox(height: 24),
          DefaultTextStyle(
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
            child: title,
          ),
          SizedBox(height: 24),
          DefaultTextStyle(
            style: TextStyle(
              fontSize: 18,
            ),
            child: description,
          ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: StylizedRaisedButton(
                text: context.msg.onboarding.permission.button.iUnderstand,
                onPressed: onPressed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

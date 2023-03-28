import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../resources/localizations.dart';
import '../buttons/feedback_button.dart';
import 'category/widget.dart';

class FeedbackTile extends StatelessWidget {
  const FeedbackTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SettingTileCategory(
      icon: FontAwesomeIcons.messages,
      titleText: context.msg.main.settings.buttons.sendFeedback,
      children: [
        FeedbackButton(),
      ],
    );
  }
}

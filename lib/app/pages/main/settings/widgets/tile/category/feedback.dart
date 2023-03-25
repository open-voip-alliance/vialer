import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../../resources/localizations.dart';
import 'widget.dart';

class FeedbackCategory extends StatelessWidget {
  final List<Widget> children;

  const FeedbackCategory({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return SettingTileCategory(
      icon: FontAwesomeIcons.messages,
      title: context.msg.main.settings.buttons.sendFeedback,
      children: children,
    );
  }
}

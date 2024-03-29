import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../resources/localizations.dart';
import 'widget.dart';

class RecentsCategory extends StatelessWidget {
  const RecentsCategory({
    required this.children,
    super.key,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SettingTileCategory(
      icon: FontAwesomeIcons.clockRotateLeft,
      titleText: context.msg.main.settings.list.recents.title,
      children: children,
    );
  }
}

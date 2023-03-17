import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../../resources/localizations.dart';
import 'widget.dart';

class RecentsCategory extends StatelessWidget {
  final List<Widget> children;

  const RecentsCategory({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return SettingTileCategory(
      icon: FontAwesomeIcons.clockRotateLeft,
      title: context.msg.main.settings.list.recents.title,
      children: children,
    );
  }
}

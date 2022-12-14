import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../../resources/localizations.dart';
import 'widget.dart';

class DebugCategory extends StatelessWidget {
  final List<Widget> children;

  const DebugCategory({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return SettingTileCategory(
      icon: FontAwesomeIcons.bug,
      title: context.msg.main.settings.list.debug.title,
      children: children,
    );
  }
}

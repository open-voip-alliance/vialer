import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../../resources/localizations.dart';
import 'widget.dart';

class CallingCategory extends StatelessWidget {
  final List<Widget> children;

  const CallingCategory({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return SettingTileCategory(
      icon: FontAwesomeIcons.phone,
      titleText: context.msg.main.settings.list.calling.title,
      children: children,
    );
  }
}

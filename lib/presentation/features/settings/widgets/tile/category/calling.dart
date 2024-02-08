import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:vialer/presentation/resources/localizations.dart';
import 'widget.dart';

class CallingCategory extends StatelessWidget {
  const CallingCategory({
    required this.children,
    super.key,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SettingTileCategory(
      icon: FontAwesomeIcons.phone,
      titleText: context.msg.main.settings.list.calling.title,
      children: children,
    );
  }
}

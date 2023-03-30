import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../../resources/localizations.dart';
import 'widget.dart';

class AdvancedSettingsCategory extends StatelessWidget {
  final List<Widget> children;

  const AdvancedSettingsCategory({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return SettingTileCategory(
      icon: FontAwesomeIcons.bug,
      titleText: context.msg.main.settings.list.advancedSettings.title,
      children: children,
    );
  }
}

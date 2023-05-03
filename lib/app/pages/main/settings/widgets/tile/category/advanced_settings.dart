import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../../resources/localizations.dart';
import 'widget.dart';

class AdvancedSettingsCategory extends StatelessWidget {
  const AdvancedSettingsCategory({
    required this.children,
    super.key,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SettingTileCategory(
      icon: FontAwesomeIcons.bug,
      titleText: context.msg.main.settings.list.advancedSettings.title,
      children: children,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../../resources/localizations.dart';
import 'widget.dart';

class TroubleshootingAudioCategory extends StatelessWidget {
  final List<Widget> children;

  const TroubleshootingAudioCategory({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return SettingTileCategory(
      icon: FontAwesomeIcons.volume,
      title: context.msg.main.settings.list.advancedSettings.troubleshooting
          .list.audio.title,
      children: children,
    );
  }
}

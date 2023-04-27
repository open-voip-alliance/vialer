import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../../resources/localizations.dart';
import 'widget.dart';

class AudioCategory extends StatelessWidget {
  const AudioCategory({
    required this.children,
    super.key,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SettingTileCategory(
      icon: FontAwesomeIcons.volumeHigh,
      titleText: context.msg.main.settings.list.audio.title,
      children: children,
    );
  }
}

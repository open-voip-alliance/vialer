import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../../resources/localizations.dart';
import 'widget.dart';

class AudioCategory extends StatelessWidget {
  final List<Widget> children;

  const AudioCategory({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return SettingTileCategory(
      icon: FontAwesomeIcons.volumeHigh,
      title: context.msg.main.settings.list.audio.title,
      children: children,
    );
  }
}

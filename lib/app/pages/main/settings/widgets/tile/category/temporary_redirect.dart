import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../../resources/localizations.dart';
import 'widget.dart';

class TemporaryRedirectCategory extends StatelessWidget {
  final List<Widget> children;

  const TemporaryRedirectCategory({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return SettingTileCategory(
      icon: FontAwesomeIcons.listTree,
      titleText: context.msg.main.temporaryRedirect.title,
      children: children,
    );
  }
}

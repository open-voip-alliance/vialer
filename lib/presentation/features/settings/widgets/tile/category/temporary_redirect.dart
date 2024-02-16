import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:vialer/presentation/resources/localizations.dart';
import 'widget.dart';

class TemporaryRedirectCategory extends StatelessWidget {
  const TemporaryRedirectCategory({
    required this.children,
    super.key,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SettingTileCategory(
      icon: FontAwesomeIcons.listTree,
      titleText: context.msg.main.temporaryRedirect.title,
      children: children,
    );
  }
}

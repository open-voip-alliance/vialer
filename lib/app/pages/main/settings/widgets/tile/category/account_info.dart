import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../../resources/localizations.dart';
import 'widget.dart';

class AccountInfoCategory extends StatelessWidget {
  final List<Widget> children;

  const AccountInfoCategory({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return SettingTileCategory(
      highlight: true,
      icon: FontAwesomeIcons.user,
      title: context.msg.main.settings.list.accountInfo.title,
      children: children,
    );
  }
}

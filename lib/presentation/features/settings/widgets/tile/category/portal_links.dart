import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../resources/localizations.dart';
import 'package:vialer/presentation/resources/theme.dart';
import 'widget.dart';

class PortalLinksCategory extends StatelessWidget {
  const PortalLinksCategory({
    required this.children,
    super.key,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SettingTileCategory(
      icon: FontAwesomeIcons.browsers,
      titleText: context.msg.main.settings.list.portalLinks.title,
      children: context.isIOS
          ? children
              .mapIndexed(
                (index, child) => index != children.lastIndex
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: child,
                      )
                    : child,
              )
              .toList()
          : children,
    );
  }
}

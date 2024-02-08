import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:vialer/presentation/resources/theme.dart';
import '../widget.dart';

class SettingLinkTile extends StatelessWidget {
  const SettingLinkTile({
    required this.title,
    this.description,
    this.onTap,
    this.center = false,
    this.bordered = true,
    this.showNavigationIndicator = true,
    super.key,
  });

  final Widget title;
  final Widget? description;

  final VoidCallback? onTap;

  final bool center;

  final bool bordered;

  /// When TRUE will show a right-arrow indicating to the user that pressing
  /// this navigates to another page.
  final bool showNavigationIndicator;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: SettingTile(
        label: title,
        description: description,
        center: center,
        child: showNavigationIndicator
            ? FaIcon(
                FontAwesomeIcons.angleRight,
                color: context.brand.theme.colors.grey4,
              )
            : Container(),
      ),
    );
  }
}

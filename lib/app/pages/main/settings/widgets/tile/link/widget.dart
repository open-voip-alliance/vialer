import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../../resources/theme.dart';
import '../widget.dart';

class SettingLinkTile extends StatelessWidget {
  final Widget title;
  final Widget? description;

  final VoidCallback? onTap;

  final bool center;

  /// See [SettingTile.bordered] for more information.
  final bool? bordered;

  /// When TRUE will show a right-arrow indicating to the user that pressing
  /// this navigates to another page.
  final bool showNavigationIndicator;

  const SettingLinkTile({
    super.key,
    required this.title,
    this.description,
    this.onTap,
    this.center = false,
    this.bordered,
    this.showNavigationIndicator = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: SettingTile(
        label: title,
        description: description,
        center: center,
        bordered: bordered,
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

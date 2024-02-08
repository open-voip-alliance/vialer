import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:vialer/presentation/resources/theme.dart';

class SettingsButton extends StatelessWidget {
  const SettingsButton({
    required this.text,
    required this.onPressed,
    this.icon,
    this.solid = true,
    super.key,
  });

  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool solid;

  @override
  Widget build(BuildContext context) {
    final textColor = solid ? Colors.white : context.brand.theme.colors.primary;
    final backgroundColor =
        solid ? context.brand.theme.colors.primary : Colors.transparent;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            FaIcon(
              icon,
              color: textColor,
              size: 16,
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: PlatformText(
              text,
              maxLines: 1,
              style: TextStyle(
                color: solid ? Colors.white : textColor,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

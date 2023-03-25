import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../resources/theme.dart';

class SettingsButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final bool solid;

  const SettingsButton({
    required this.text,
    required this.icon,
    required this.onPressed,
    this.solid = true,
  });

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
          FaIcon(
            icon,
            color: textColor,
            size: 16,
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
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

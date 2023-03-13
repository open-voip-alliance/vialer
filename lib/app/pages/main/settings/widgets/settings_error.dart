import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../resources/theme.dart';

class SettingsError extends StatelessWidget {
  final bool visible;
  final String message;

  SettingsError({required this.visible, required this.message});

  @override
  Widget build(BuildContext context) {
    final color = context.brand.theme.colors.red1;

    return Visibility(
      visible: visible,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
            child: const FaIcon(
              FontAwesomeIcons.exclamation,
              size: 10,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            message,
            style: TextStyle(color: color),
          )
        ],
      ),
    );
  }
}

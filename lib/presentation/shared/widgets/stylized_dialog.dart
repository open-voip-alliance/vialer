import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../features/survey/widgets/big_header.dart';

class StylizedDialog extends StatelessWidget {
  StylizedDialog({
    required this.content,
    required this.headerIcon,
    required this.title,
    this.subtitle,
    List<Widget>? actions,
    this.closeButtonText,
    super.key,
  }) : actions = actions ?? [];
  final IconData headerIcon;

  final String title;

  final String? subtitle;

  final Widget content;

  final List<Widget> actions;

  /// When set to a text widget, a close button will be rendered as the final
  /// action that simply dismisses the dialog. To not include a close button
  /// or to provide a custom one, simply leave this as null.
  final Text? closeButtonText;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: BigHeader(
        icon: FaIcon(
          headerIcon,
          size: 50,
          color: Colors.white.withOpacity(0.2),
        ),
        text: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
      ),
      titlePadding: EdgeInsets.zero,
      content: content,
      actions: [
        ...actions,
        if (closeButtonText != null)
          TextButton(
            child: closeButtonText!,
            onPressed: () => Navigator.of(context).pop(),
          ),
      ],
    );
  }
}

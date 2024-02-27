import 'package:flutter/material.dart';
import 'package:vialer/presentation/resources/theme.dart';

void showSnackBar(
  BuildContext context, {
  required Widget icon,
  required Widget label,
  EdgeInsets padding = EdgeInsets.zero,
  EdgeInsets contentPadding = const EdgeInsets.symmetric(horizontal: 16),
  Duration duration = const Duration(seconds: 4),
  ScaffoldMessengerState? scaffoldMessengerState,
  Color? backgroundColor,
  Color? contentColor,
  Widget divider = const SizedBox(width: 24),
  bool excludeSemantics = false,
}) {
  backgroundColor =
      backgroundColor ?? context.brand.theme.colors.buttonBackground;
  contentColor =
      contentColor ?? context.brand.theme.colors.raisedColoredButtonText;

  (scaffoldMessengerState ?? ScaffoldMessenger.of(context)).showSnackBar(
    SnackBar(
      duration: duration,
      behavior: SnackBarBehavior.fixed,
      backgroundColor: backgroundColor,
      content: ExcludeSemantics(
        excluding: excludeSemantics,
        child: Padding(
          padding: contentPadding,
          child: Row(
            children: <Widget>[
              IconTheme.merge(
                data: IconThemeData(color: contentColor, size: 16),
                child: icon,
              ),
              divider,
              Expanded(
                child: Padding(
                  padding: padding,
                  child: DefaultTextStyle.merge(
                    style: TextStyle(
                      color: contentColor,
                      fontSize: 16,
                    ),
                    child: label,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

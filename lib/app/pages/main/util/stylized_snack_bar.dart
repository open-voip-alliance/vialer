import 'package:flutter/material.dart';

import '../../../resources/theme.dart';

void showSnackBar(
  BuildContext context, {
  @required Widget icon,
  @required Widget label,
  EdgeInsets padding = EdgeInsets.zero,
  Duration duration = const Duration(seconds: 4),
}) {
  final backgroundColor = BrandTheme.of(
    context,
    listen: false,
  ).buttonColor;

  final contentColor = BrandTheme.of(
    context,
    listen: false,
  ).buttonColoredRaisedTextColor;

  Scaffold.of(context).showSnackBar(
    SnackBar(
      duration: duration,
      behavior: SnackBarBehavior.fixed,
      backgroundColor: backgroundColor,
      content: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: Row(
          children: <Widget>[
            IconTheme.merge(
              data: IconThemeData(
                color: contentColor,
                size: 16,
              ),
              child: icon,
            ),
            SizedBox(width: 24),
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
  );
}

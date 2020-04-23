import 'package:flutter/material.dart';

import '../../../resources/theme.dart';

void showSnackBar(
  BuildContext context, {
  @required String text,
  EdgeInsets padding = EdgeInsets.zero,
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
      behavior: SnackBarBehavior.fixed,
      backgroundColor: backgroundColor,
      content: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: Row(
          children: <Widget>[
            Icon(
              VialerSans.copy,
              color: contentColor,
              size: 16,
            ),
            SizedBox(width: 24),
            Expanded(
              child: Padding(
                padding: padding,
                child: Text(
                  text,
                  style: TextStyle(
                    color: contentColor,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

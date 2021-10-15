import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final String data;
  final EdgeInsets padding;

  const Header(
    this.data, {
    Key? key,
    this.padding = const EdgeInsets.only(bottom: 8),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const maxWidth = 411;

    final mediaQuery = MediaQuery.of(context);

    final textScaleFactor =
        mediaQuery.size.width.clamp(0, maxWidth) / (maxWidth * 1.04) -
            0.05; // Take some off in case that bold text is enabled on iOS.

    return Padding(
      padding: padding,
      child: Text(
        data,
        // Never make title bigger based on font settings.
        textScaleFactor: textScaleFactor.clamp(0.0, 1.0),
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: 38,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

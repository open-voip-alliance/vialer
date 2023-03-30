import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final String data;
  final EdgeInsets padding;

  const Header(
    this.data, {
    Key? key,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const maxWidth = 411;

    final mediaQuery = MediaQuery.of(context);

    return Padding(
      padding: padding,
      child: MediaQuery(
        data: mediaQuery.copyWith(
          // Never make title bigger based on font settings.
          textScaleFactor: mediaQuery.textScaleFactor.clamp(0, 1.0),
        ),
        child: Text(
          data,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: mediaQuery.size.width.clamp(0, maxWidth) /
                (maxWidth * 1.04) *
                28, // Original font size
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

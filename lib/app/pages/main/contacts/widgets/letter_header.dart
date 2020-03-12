import 'package:flutter/material.dart';

import '../../../../resources/theme.dart';

class LetterHeader extends StatelessWidget {
  final String letter;

  const LetterHeader({Key key, @required this.letter}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 16,
        bottom: 4,
      ),
      child: Text(
        letter,
        style: TextStyle(
          color: context.isIOS ? context.brandTheme.grey1 : context.brandTheme.grey5,
          fontSize: 16,
          fontWeight: context.isIOS ? FontWeight.normal : FontWeight.bold,
        ),
      ),
    );
  }
}

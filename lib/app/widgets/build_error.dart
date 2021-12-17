import 'package:flutter/material.dart';

import '../resources/localizations.dart';
import '../resources/theme.dart';

class BuildError extends StatelessWidget {
  const BuildError({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      context.msg.buildError.anErrorOccurred,
      textScaleFactor: 1,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 14,
        color: context.brand.theme.colors.red1,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

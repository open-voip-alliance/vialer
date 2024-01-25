import 'package:flutter/material.dart';

import '../../resources/localizations.dart';
import '../../resources/theme.dart';

class BuildError extends StatelessWidget {
  const BuildError({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      context.msg.buildError.anErrorOccurred,
      textScaler: TextScaler.linear(1),
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 14,
        color: context.brand.theme.colors.red1,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

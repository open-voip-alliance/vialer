import 'package:flutter/material.dart';

final vialerTheme = ThemeData(
  primaryColor: VialerColors.primary,
  primaryColorDark: VialerColors.primaryDark,
  buttonTheme: ButtonThemeData(
    height: 42,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4),
    ),
    buttonColor: Colors.white,
  ),
);

abstract class VialerTheme {
  static const gradient = LinearGradient(
    colors: [VialerColors.gradientStart, VialerColors.gradientEnd],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static final gradientReversed = LinearGradient(
    colors: gradient.colors,
    begin: gradient.end,
    end: gradient.begin,
  );
}

abstract class VialerColors {
  static const primary = Color(0xFFDF662E);
  static const primaryDark = Color(0xFFDE531B);
  static const primaryDarker = Color(0xFFD45400);

  static const highlight = Color(0xFF3E50B4);

  static const gradientStart = Color(0xFFFF8213);
  static const gradientEnd = Color(0xFFE94E1B);
}

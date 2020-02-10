import 'package:flutter/material.dart';

final vialerTheme = ThemeData(
  primaryColor: VialerColors.primary,
  buttonTheme: ButtonThemeData(
    height: 42,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4),
    ),
    buttonColor: Colors.white,
  ),
);

abstract class VialerTheme {
  static const onboardingGradient = LinearGradient(
    colors: [
      VialerColors.onboardingGradientStart,
      VialerColors.onboardingGradientEnd,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static final onboardingGradientReversed = LinearGradient(
    colors: onboardingGradient.colors,
    begin: onboardingGradient.end,
    end: onboardingGradient.begin,
  );

  static const splashScreenGradient = LinearGradient(
    colors: [
      VialerColors.splashScreenGradientStart,
      VialerColors.splashScreenGradientEnd
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

abstract class VialerColors {
  static const primary = Color(0xFFFFA257);

  static const grey1 = Color(0xFFCCCCCC);
  static const grey2 = Color(0xFFD8D8D8);
  static const grey3 = Color(0xFFE0E0E0);
  static const grey4 = Color(0xFF8F8F8F);
  static const grey5 = Color(0xFF8B95A3);

  static const green = Color(0xFF28CA42);

  static const onboardingGradientStart = Color(0xFFFF8213);
  static const onboardingGradientEnd = Color(0xFFE94E1B);

  static const splashScreenGradientStart = Color(0xFFFFA257);
  static const splashScreenGradientEnd = Color(0xFFFF7B24);
}

abstract class VialerSans {
  static const _family = 'VialerSans';

  static const brandVialer = IconData(0xE98A, fontFamily: _family);
  static const user = IconData(0xE964,fontFamily: _family);
  static const lockOn = IconData(0xE90C, fontFamily: _family);
  static const lockOff = IconData(0xE90A, fontFamily: _family);
  static const phone = IconData(0xE980, fontFamily: _family);
  static const dialpad = IconData(0xE961, fontFamily: _family);
  static const clock = IconData(0xE95E, fontFamily: _family);
  static const contacts = IconData(0xE967, fontFamily: _family);
  static const settings = IconData(0xE949, fontFamily: _family);
  static const correct = IconData(0xE910, fontFamily: _family);
  static const ellipsis = IconData(0xE981, fontFamily: _family);
  static const incomingCall = IconData(0xE924, fontFamily: _family);
  static const outgoingCall = IconData(0xE92A, fontFamily: _family);
}

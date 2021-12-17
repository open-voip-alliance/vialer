import 'dart:ui';

import 'raw_colors.dart';

// Regex (for IntelliJ) for find and replace to automatically
// access the correct property from raw:
//
// Fields:
// Find: final int ([A-z0-9]+);
// Replace: final Color $1;
//
// Initializer:
// Find: ([A-z0-9]+),
// Replace: $1 = raw.$1.color,
class Colors {
  Colors(RawColors raw)
      : primary = raw.primary.color,
        primaryDark = raw.primaryDark.color,
        primaryLight = raw.primaryLight.color,
        onPrimary = raw.onPrimary.color,
        grey1 = raw.grey1.color,
        grey2 = raw.grey2.color,
        grey3 = raw.grey3.color,
        grey4 = raw.grey4.color,
        grey5 = raw.grey5.color,
        grey6 = raw.grey6.color,
        settingsBackgroundHighlight = raw.settingsBackgroundHighlight.color,
        green1 = raw.green1.color,
        green2 = raw.green2.color,
        green3 = raw.green3.color,
        red1 = raw.red1.color,
        answeredElsewhere = raw.answeredElsewhere.color,
        notAvailable = raw.notAvailable.color,
        notAvailableAccent = raw.notAvailableAccent.color,
        availableElsewhere = raw.availableElsewhere.color,
        availableElsewhereAccent = raw.availableElsewhereAccent.color,
        dnd = raw.dnd.color,
        dndAccent = raw.dndAccent.color,
        available = raw.available.color,
        availableAccent = raw.availableAccent.color,
        splashScreen = raw.splashScreen.color,
        onboardingGradientStart = raw.onboardingGradientStart.color,
        onboardingGradientEnd = raw.onboardingGradientEnd.color,
        primaryGradientStart = raw.primaryGradientStart.color,
        primaryGradientEnd = raw.primaryGradientEnd.color,
        onPrimaryGradient = raw.onPrimaryGradient.color,
        errorBorder = raw.errorBorder.color,
        errorContent = raw.errorContent.color,
        errorBackground = raw.errorBackground.color,
        textButtonForeground = raw.textButtonForeground.color,
        buttonBackground = raw.buttonBackground.color,
        buttonShade = raw.buttonShade.color,
        raisedColoredButtonText = raw.raisedColoredButtonText.color,
        appBarForeground = raw.appBarForeground.color,
        appBarBackground = raw.appBarBackground.color,
        notificationBackground = raw.notificationBackground.color;

  final Color primary;
  final Color primaryDark;
  final Color primaryLight;

  /// Color for use when the [primary] color is the background.
  final Color onPrimary;

  final Color grey1;
  final Color grey2;
  final Color grey3;
  final Color grey4;
  final Color grey5;
  final Color grey6;

  final Color settingsBackgroundHighlight;

  final Color green1;
  final Color green2;
  final Color green3;

  final Color red1;

  final Color answeredElsewhere;

  final Color notAvailable;
  final Color notAvailableAccent;

  final Color availableElsewhere;
  final Color availableElsewhereAccent;

  final Color dnd;
  final Color dndAccent;

  final Color available;
  final Color availableAccent;

  final Color splashScreen;

  final Color onboardingGradientStart;
  final Color onboardingGradientEnd;

  final Color primaryGradientStart;
  final Color primaryGradientEnd;

  final Color onPrimaryGradient;

  final Color errorBorder;
  final Color errorContent;
  final Color errorBackground;

  final Color textButtonForeground;
  final Color buttonBackground;
  final Color buttonShade;
  final Color raisedColoredButtonText;

  final Color appBarForeground;
  final Color appBarBackground;

  /// Only used by the Android Phone Lib, here for completionist's sake.
  final Color notificationBackground;
}

extension on int {
  Color get color => Color(this);
}

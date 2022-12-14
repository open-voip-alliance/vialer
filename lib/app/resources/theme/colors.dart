import 'dart:ui';

import 'color_values.dart';

// Regex (for IntelliJ) for find and replace to automatically
// access the correct property from the values:
//
// Fields:
// Find: final int ([A-z0-9]+);
// Replace: final Color $1;
//
// Initializer:
// Find: ([A-z0-9]+),
// Replace: $1 = v.$1.color,
class Colors {
  Colors(ColorValues v)
      : primary = v.primary.color,
        primaryDark = v.primaryDark.color,
        primaryLight = v.primaryLight.color,
        onPrimary = v.onPrimary.color,
        grey1 = v.grey1.color,
        grey2 = v.grey2.color,
        grey3 = v.grey3.color,
        grey4 = v.grey4.color,
        grey5 = v.grey5.color,
        grey6 = v.grey6.color,
        settingsBackgroundHighlight = v.settingsBackgroundHighlight.color,
        green1 = v.green1.color,
        green2 = v.green2.color,
        green3 = v.green3.color,
        red1 = v.red1.color,
        answeredElsewhere = v.answeredElsewhere.color,
        notAvailable = v.notAvailable.color,
        notAvailableAccent = v.notAvailableAccent.color,
        availableElsewhere = v.availableElsewhere.color,
        availableElsewhereAccent = v.availableElsewhereAccent.color,
        dnd = v.dnd.color,
        dndAccent = v.dndAccent.color,
        available = v.available.color,
        availableAccent = v.availableAccent.color,
        splashScreen = v.splashScreen.color,
        onboardingGradientStart = v.onboardingGradientStart.color,
        onboardingGradientEnd = v.onboardingGradientEnd.color,
        primaryGradientStart = v.primaryGradientStart.color,
        primaryGradientEnd = v.primaryGradientEnd.color,
        onPrimaryGradient = v.onPrimaryGradient.color,
        errorBorder = v.errorBorder.color,
        errorContent = v.errorContent.color,
        errorBackground = v.errorBackground.color,
        textButtonForeground = v.textButtonForeground.color,
        buttonBackground = v.buttonBackground.color,
        buttonShade = v.buttonShade.color,
        raisedColoredButtonText = v.raisedColoredButtonText.color,
        appBarForeground = v.appBarForeground.color,
        appBarBackground = v.appBarBackground.color,
        notificationBackground = v.notificationBackground.color;

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

// Never import anything from Flutter here!

import 'package:json_annotation/json_annotation.dart';

import '../../../domain/user/brand.dart';

part 'color_values.g.dart';

// Why ints?
//
// The reason a type of int is used for all values instead of
// Color, is because dart:ui (where Color comes from) is not available
// on non-Flutter Dart. This means that when running a script locally
// or on CI that wants to use these values, fails.
//
// Specifically a script for generating native values uses these.
//
// Another small bonus is that writing color definitions is shorter since you
// don't have to call the Color constructor everytime!
@JsonSerializable(createFactory: false)
class ColorValues {
  const ColorValues({
    required this.primary,
    required this.primaryDark,
    required this.primaryLight,
    this.onPrimary = 0xFFFFFFFF,
    this.grey1 = 0xFFCCCCCC,
    this.grey2 = 0xFFD8D8D8,
    this.grey3 = 0xFFE0E0E0,
    this.grey4 = 0xFF8F8F8F,
    this.grey5 = 0xFF8B95A3,
    this.grey6 = 0xFF666666,
    this.settingsBackgroundHighlight = 0xFFEFF0F8,
    this.green1 = 0xFF28CA42,
    this.green2 = 0xFFACF5A6,
    this.green3 = 0xFF046614,
    this.red1 = 0xFFDA534F,
    this.answeredElsewhere = 0xFF1F86FF,
    this.notAvailable = 0xFF840D09,
    this.notAvailableAccent = 0xFFFFBABF,
    this.availableElsewhere = 0xFF0047CE,
    this.availableElsewhereAccent = 0xFFECEEF7,
    this.dnd = 0xFFD1530B,
    this.dndAccent = 0xFFFFC999,
    this.available = 0xFF075B15,
    this.availableAccent = 0xFFA2F39C,
    required this.splashScreen,
    required this.onboardingGradientStart,
    required this.onboardingGradientEnd,
    required this.primaryGradientStart,
    required this.primaryGradientEnd,
    int? onPrimaryGradient,
    this.errorBorder = 0x57DA534F,
    this.errorContent = 0xFFDA534F,
    this.errorBackground = 0x4D000000,
    int? textButtonForeground,
    int? buttonBackground,
    int? buttonShade,
    int? buttonRaisedColorText,
    this.appBarForeground = 0xFFFFFFFF,
    int? appBarBackground,
    int? notificationBackground,
    this.userAvailabilityAvailable = 0xFFACF5A6,
    this.userAvailabilityAvailableAccent = 0xFF046614,
    this.userAvailabilityBusy = 0xFFFFADAD,
    this.userAvailabilityBusyAccent = 0xFF8F0A06,
    this.userAvailabilityUnavailable = 0xFFFFD0A3,
    this.userAvailabilityUnavailableAccent = 0xFFD45400,
    this.userAvailabilityUnknown = 0xFFF5F5F5,
    this.userAvailabilityUnknownAccent = 0xFF666666,
  })  : onPrimaryGradient = onPrimaryGradient ?? onPrimary,
        textButtonForeground = textButtonForeground ?? primary,
        buttonBackground = buttonBackground ?? primaryLight,
        raisedColoredButtonText = buttonRaisedColorText ?? primaryDark,
        buttonShade = buttonShade ?? primary,
        appBarBackground = appBarBackground ?? primary,
        notificationBackground = notificationBackground ?? primary;

  final int primary;
  final int primaryDark;
  final int primaryLight;

  /// Color for use when the [primary] color is the background.
  final int onPrimary;

  final int grey1;
  final int grey2;
  final int grey3;
  final int grey4;
  final int grey5;
  final int grey6;

  final int settingsBackgroundHighlight;

  final int green1;
  final int green2;
  final int green3;

  final int red1;

  final int answeredElsewhere;

  final int notAvailable;
  final int notAvailableAccent;

  final int availableElsewhere;
  final int availableElsewhereAccent;

  final int dnd;
  final int dndAccent;

  final int available;
  final int availableAccent;

  final int splashScreen;

  final int onboardingGradientStart;
  final int onboardingGradientEnd;

  final int primaryGradientStart;
  final int primaryGradientEnd;

  final int onPrimaryGradient;

  final int errorBorder;
  final int errorContent;
  final int errorBackground;

  final int textButtonForeground;
  final int buttonBackground;
  final int buttonShade;
  final int raisedColoredButtonText;

  final int appBarForeground;
  final int appBarBackground;

  /// Name should not be changed, this color is expected by
  /// the Android Phone Lib.
  final int notificationBackground;

  final int userAvailabilityAvailable;
  final int userAvailabilityAvailableAccent;
  final int userAvailabilityBusy;
  final int userAvailabilityBusyAccent;
  final int userAvailabilityUnavailable;
  final int userAvailabilityUnavailableAccent;
  final int userAvailabilityUnknown;
  final int userAvailabilityUnknownAccent;

  /// Defaults should be left as-is.
  const ColorValues.vialer({
    int primary = 0xFFFF7B24,
    int primaryDark = 0xFFD45400,
    int primaryLight = 0xFFFFD0A3,
    int onboardingGradientStart = 0xFFFF8213,
    int onboardingGradientEnd = 0xFFE94E1B,
  }) : this(
          primary: primary,
          primaryDark: primaryDark,
          primaryLight: primaryLight,
          splashScreen: primaryLight,
          onboardingGradientStart: onboardingGradientStart,
          onboardingGradientEnd: onboardingGradientEnd,
          primaryGradientStart: onboardingGradientStart,
          primaryGradientEnd: onboardingGradientEnd,
          textButtonForeground: primaryDark,
          appBarForeground: primaryDark,
          appBarBackground: primaryLight,
        );

  /// Defaults should be left as-is.
  const ColorValues.voys({
    int primary = 0xFF3B14B9,
    int primaryDark = 0xFF31227A,
    int primaryLight = 0xFFC0B4E8,
  }) : this(
          primary: primary,
          primaryDark: primaryDark,
          primaryLight: primaryLight,
          splashScreen: primary,
          onboardingGradientStart: 0xFFC0B4E8,
          onboardingGradientEnd: primaryDark,
          primaryGradientStart: primary,
          primaryGradientEnd: 0xFF7F67D1,
          buttonBackground: primary,
          buttonShade: primaryDark,
          buttonRaisedColorText: 0xFFFFFFFF,
        );

  /// Defaults should be left as-is.
  const ColorValues.verbonden({
    int primary = 0xFF003A63,
    int primaryDark = 0xFF01243C,
    int primaryLight = 0xFF70D8FF,
  }) : this(
          primary: primary,
          primaryDark: primaryDark,
          primaryLight: primaryLight,
          splashScreen: 0xFFFFFFFF,
          onboardingGradientStart: 0xFF70D8FF,
          onboardingGradientEnd: primary,
          primaryGradientStart: primary,
          primaryGradientEnd: primaryDark,
          buttonBackground: primary,
          buttonShade: primaryDark,
          buttonRaisedColorText: 0xFFFFFFFF,
        );

  /// Defaults should be left as-is.
  const ColorValues.annabel({
    int primary = 0xFF5F4B8B,
    int primaryDark = 0xFF3C247F,
    int primaryLight = 0xFFD9D2EF,
  }) : this(
          primary: primary,
          primaryDark: primaryDark,
          primaryLight: primaryLight,
          splashScreen: primaryLight,
          onboardingGradientStart: primaryLight,
          onboardingGradientEnd: primaryDark,
          primaryGradientStart: primary,
          primaryGradientEnd: primaryDark,
          buttonBackground: primary,
          buttonShade: primaryDark,
          buttonRaisedColorText: 0xFFFFFFFF,
        );

  Map<String, dynamic> toJson() => _$ColorValuesToJson(this);
}

extension BrandColors on Brand {
  /// The color values associated with this [Brand].
  ///
  /// To use `dart:ui` `Color`s, use `brand.theme.colors`.
  ColorValues get colorValues => select(
        vialer: const ColorValues.vialer(),
        voys: const ColorValues.voys(),
        verbonden: const ColorValues.verbonden(),
        annabel: const ColorValues.annabel(),
      );
}

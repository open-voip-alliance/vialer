// Never import anything from Flutter here!

import 'package:json_annotation/json_annotation.dart';

import '../../../domain/user/brand.dart';

part 'colors.g.dart';

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
class Colors {
  const Colors({
    required this.primary,
    required this.primaryDark,
    required this.primaryLight,
    required this.splashScreen,
    required this.primaryGradientStart,
    required this.primaryGradientEnd,
    this.infoText = 0xFF666666,
    this.disabledText = 0xFFA3A3A3,
    this.onPrimary = 0xFFFFFFFF,
    this.grey1 = 0xFFCCCCCC,
    this.grey2 = 0xFFD8D8D8,
    this.grey3 = 0xFFE0E0E0,
    this.grey4 = 0xFF8F8F8F,
    this.grey5 = 0xFF8B95A3,
    this.grey6 = 0xFF666666,
    this.grey7 = 0xFFF6F6F6,
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
    int? onPrimaryGradient,
    this.errorBorder = 0x57DA534F,
    this.errorContent = 0xFFDA534F,
    this.errorBackground = 0x4D000000,
    int? textButtonForeground,
    int? buttonBackground,
    int? buttonShade,
    this.raisedColoredButtonText = 0xFFFFFFFF,
    this.appBarForeground = 0xFFFFFFFF,
    int? appBarBackground,
    int? notificationBackground,
    this.userAvailabilityAvailable = 0xFFACF5A6,
    this.userAvailabilityAvailableAccent = 0xFF046614,
    this.userAvailabilityAvailableAvatar = 0xFF63E06F,
    this.userAvailabilityBusy = 0xFFFFADAD,
    this.userAvailabilityBusyAccent = 0xFF8F0A06,
    this.userAvailabilityBusyAvatar = 0xFFFFA257,
    this.userAvailabilityUnavailable = 0xFFFFD0A3,
    this.userAvailabilityUnavailableAccent = 0xFFD45400,
    this.userAvailabilityUnavailableIcon = 0xFFFF7B24,
    this.userAvailabilityUnknown = 0xFFF5F5F5,
    this.userAvailabilityUnknownAccent = 0xFF666666,
    this.userAvailabilityOffline = 0xFF2A3041,
    this.userAvailabilityOfflineAccent = 0xFFFFFFFF,
    this.availabilityHeader = 0xFF2A3041,
    this.settingsBadge = 0xFFF15A29,
  })  : onPrimaryGradient = onPrimaryGradient ?? onPrimary,
        textButtonForeground = textButtonForeground ?? primary,
        buttonBackground = buttonBackground ?? primaryLight,
        buttonShade = buttonShade ?? primary,
        appBarBackground = appBarBackground ?? primary,
        notificationBackground = notificationBackground ?? primary;

  /// Defaults should be left as-is.
  const Colors.vialer({
    int primaryDarkest = 0xFFD45400,
    int primaryDarker = 0xFFE6640E,
    int primary = 0xFFFF7B24,
    int primaryLighter = 0xFFFDBA74,
    int primaryLightest = 0xFFFFEDD5,
  }) : this(
          primary: primary,
          primaryDark: primaryDarkest,
          primaryLight: primaryLightest,
          splashScreen: primaryLightest,
          primaryGradientStart: 0xFFFF8213,
          primaryGradientEnd: 0xFFE94E1B,
          buttonBackground: primary,
          appBarForeground: primaryDarkest,
          appBarBackground: primaryLightest,
        );

  /// Defaults should be left as-is.
  const Colors.voys({
    int primaryDarkest = 0xFF1E1B4B,
    int primaryDarker = 0xFF000577,
    int primary = 0xFF270597,
    int primaryLighter = 0xFFB7B2F8,
    int primaryLightest = 0xFFF0F0FF,
  }) : this(
          primary: primary,
          primaryDark: primaryDarkest,
          primaryLight: primaryLightest,
          splashScreen: primary,
          primaryGradientStart: primary,
          primaryGradientEnd: 0xFF7F67D1,
          buttonBackground: primary,
          buttonShade: primaryDarkest,
        );

  /// Defaults should be left as-is.
  const Colors.verbonden({
    int primaryDarkest = 0xFF01243C,
    int primaryDarker = 0xFF1A2D75,
    int primary = 0xFF3336AD,
    int primaryLighter = 0xFF8385D6,
    int primaryLightest = 0xFFD2D3FF,
  }) : this(
          primary: primary,
          primaryDark: primaryDarkest,
          primaryLight: primaryLightest,
          splashScreen: 0xFFFFFFFF,
          primaryGradientStart: primary,
          primaryGradientEnd: primaryDarkest,
          buttonBackground: primary,
          buttonShade: primaryDarkest,
        );

  /// Defaults should be left as-is.
  const Colors.annabel({
    int primaryDarkest = 0xFF160E2D,
    int primaryDarker = 0xFF382E52,
    int primary = 0xFF645394,
    int primaryLighter = 0xFFABA1C5,
    int primaryLightest = 0xFFEDE9F9,
  }) : this(
          primary: primary,
          primaryDark: primaryDarkest,
          primaryLight: primaryLightest,
          splashScreen: primaryLightest,
          primaryGradientStart: primary,
          primaryGradientEnd: primaryDarkest,
          buttonBackground: primary,
          buttonShade: primaryDarkest,
        );

  final int primary;
  final int primaryDark;
  final int primaryLight;

  final int infoText;
  final int disabledText;

  /// Color for use when the [primary] color is the background.
  final int onPrimary;

  final int grey1;
  final int grey2;
  final int grey3;
  final int grey4;
  final int grey5;
  final int grey6;
  final int grey7;

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
  final int userAvailabilityAvailableAvatar;
  final int userAvailabilityBusy;
  final int userAvailabilityBusyAccent;
  final int userAvailabilityBusyAvatar;
  final int userAvailabilityUnavailable;
  final int userAvailabilityUnavailableAccent;
  final int userAvailabilityUnavailableIcon;
  final int userAvailabilityUnknown;
  final int userAvailabilityUnknownAccent;
  final int userAvailabilityOffline;
  final int userAvailabilityOfflineAccent;

  final int availabilityHeader;
  final int settingsBadge;

  Map<String, dynamic> toJson() => _$ColorsToJson(this);
}

extension BrandColors on Brand {
  /// The color values associated with this [Brand].
  ///
  /// To use `dart:ui` `Color`s, use `brand.theme.colors`.
  Colors get colors => select(
        vialer: const Colors.vialer(),
        voys: const Colors.voys(),
        verbonden: const Colors.verbonden(),
        annabel: const Colors.annabel(),
      );
}

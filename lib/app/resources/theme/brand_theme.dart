import 'package:flutter/material.dart' hide Colors;

import '../../../domain/entities/brand.dart';
import 'brand_icon_code_points.dart';
import 'color_values.dart';
import 'colors.dart';

@immutable
class BrandTheme {
  const BrandTheme(this.colors, this.logo);

  final Colors colors;
  final IconData logo;

  LinearGradient get splashScreenGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          colors.splashScreen,
          colors.splashScreen,
        ],
      );

  LinearGradient get onboardingGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          colors.onboardingGradientStart,
          colors.onboardingGradientEnd,
        ],
      );

  LinearGradient get onboardingGradientReversed => LinearGradient(
        colors: onboardingGradient.colors,
        begin: onboardingGradient.end,
        end: onboardingGradient.begin,
      );

  LinearGradient get primaryGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          colors.primaryGradientStart,
          colors.primaryGradientEnd,
        ],
      );

  ThemeData get themeData {
    return ThemeData(
      primaryColor: colors.primary,
      primaryColorDark: colors.primaryDark,
      primaryColorLight: colors.primaryLight,
      appBarTheme: AppBarTheme(
        color: colors.appBarBackground,
        titleTextStyle: TextStyle(
          color: colors.appBarForeground,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(
          color: colors.appBarForeground,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(
            colors.textButtonForeground,
          ),
        ),
      ),
    );
  }
}

extension ThemeOfBrand on Brand {
  // Theme is cached here to prevent constant object creation.
  static BrandTheme? _theme;

  BrandTheme get theme => _theme ??= BrandTheme(
        Colors(colorValues),
        icon,
      );
}

extension BrandIcon on Brand {
  IconData get icon {
    const family = 'BrandIcons';

    // Always use a const constructor for IconData, don't use
    // the `iconCodePoint` extension directly.
    // Otherwise, icons are not tree-shaken.
    return select(
      vialer: const IconData(BrandIconCodePoints.vialer, fontFamily: family),
      voys: const IconData(BrandIconCodePoints.voys, fontFamily: family),
      verbonden: const IconData(
        BrandIconCodePoints.verbonden,
        fontFamily: family,
      ),
      annabel: const IconData(
        BrandIconCodePoints.annabel,
        fontFamily: family,
      ),
    );
  }
}

extension ThemeTargetPlatform on BuildContext {
  bool get isIOS => Theme.of(this).platform == TargetPlatform.iOS;

  bool get isAndroid => Theme.of(this).platform == TargetPlatform.android;
}

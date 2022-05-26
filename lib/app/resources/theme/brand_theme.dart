import 'package:flutter/material.dart' hide Colors;

import '../../../domain/entities/brand.dart';
import 'colors.dart';
import 'raw_colors.dart';
import 'vialer_sans.dart';

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

// Theme is cached here to prevent constant object creation.
BrandTheme? _theme;

extension ThemeOfBrand on Brand {
  BrandTheme get theme => _theme ??= BrandTheme(
        Colors(rawColors),
        logo,
      );
}

// Unfortunately this logic has to be copied over, if we construct an
// IconData dynamically using rawLogo Flutter won't tree-shake icons.
extension on Brand {
  IconData get logo {
    if (isVialer || isVialerStaging) {
      return VialerSans.brandVialer;
    } else if (isVoys) {
      return VialerSans.brandVoys;
    } else if (isVerbonden) {
      return VialerSans.brandVerbonden;
    } else if (isAnnabel) {
      return VialerSans.brandAnnabel;
    } else {
      throw UnsupportedError('A logo must be added for $identifier');
    }
  }
}

extension ThemeTargetPlatform on BuildContext {
  bool get isIOS => Theme.of(this).platform == TargetPlatform.iOS;

  bool get isAndroid => Theme.of(this).platform == TargetPlatform.android;
}

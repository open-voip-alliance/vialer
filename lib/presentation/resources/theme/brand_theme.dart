import 'package:flutter/material.dart' hide Colors;
import 'package:flutter/material.dart' as MaterialColors show Colors;
import 'package:vialer/presentation/resources/theme/colors.dart';

import '../../../data/models/user/brand.dart';
import 'brand_icon_code_points.dart';
import 'colors.vialer.dart';

@immutable
class BrandTheme {
  BrandTheme(this.colors, this.logo);

  final FlutterColors colors;
  final IconData logo;

  late final splashScreenGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      colors.splashScreen,
      colors.splashScreen,
    ],
  );

  late final primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      colors.primaryGradientStart,
      colors.primaryGradientEnd,
    ],
  );

  late final fieldBorderRadius = BorderRadius.circular(8);

  late final fieldBoxDecoration = BoxDecoration(
    border: Border.all(
      color: colors.grey3,
    ),
    borderRadius: fieldBorderRadius,
  );

  late final themeData = ThemeData(
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
        foregroundColor: WidgetStateProperty.all(
          colors.textButtonForeground,
        ),
      ),
    ),
    splashColor: MaterialColors.Colors.transparent,
  );
}

extension ThemeOfBrand on Brand {
  // Theme is cached here to prevent constant object creation.
  static BrandTheme? _theme;

  BrandTheme get theme => _theme ??= BrandTheme(
        FlutterColors(colors),
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

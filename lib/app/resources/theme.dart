import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

extension ThemeTargetPlatform on BuildContext {
  bool get isIOS => Theme.of(this).platform == TargetPlatform.iOS;

  bool get isAndroid => Theme.of(this).platform == TargetPlatform.android;
}

abstract class BrandTheme {
  get onboardingGradient => LinearGradient(
        colors: [
          onboardingGradientStart,
          onboardingGradientEnd,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  get onboardingGradientReversed => LinearGradient(
        colors: onboardingGradient.colors,
        begin: onboardingGradient.end,
        end: onboardingGradient.begin,
      );

  get splashScreenGradient => LinearGradient(
        colors: [splashScreenColor, splashScreenColor],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  IconData get logo;

  Color get primary;

  Color get primaryDark;

  Color get primaryLight;

  final grey1 = Color(0xFFCCCCCC);
  final grey2 = Color(0xFFD8D8D8);
  final grey3 = Color(0xFFE0E0E0);
  final grey4 = Color(0xFF8F8F8F);
  final grey5 = Color(0xFF8B95A3);

  final green1 = Color(0xFF28CA42);
  final green2 = Color(0xFFACF5A6);
  final green3 = Color(0xFF046614);

  Color get splashScreenColor;

  Color get onboardingGradientStart;

  Color get onboardingGradientEnd;

  Color get errorBorderColor;

  Color get errorContentColor;

  Color get buttonColor => primaryLight;

  Color get buttonShadeColor => primary;

  Color get buttonRaisedTextColor => primaryDark;

  Color get buttonColoredRaisedTextColor => primaryDark;

  ThemeData get themeData {
    return ThemeData(
      primaryColor: primary,
      primaryColorDark: primaryDark,
      primaryColorLight: primaryLight,
      appBarTheme: AppBarTheme(
        color: primaryLight,
        textTheme: TextTheme(
          title: TextStyle(
            color: primaryDark,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(
          color: primaryDark,
        ),
      ),
    );
  }

  static BrandTheme of(BuildContext context, {bool listen = true}) =>
      Provider.of<BrandTheme>(context, listen: listen);
}

class VialerTheme extends BrandTheme {
  @override
  IconData get logo => VialerSans.brandVialer;

  @override
  final primary = Color(0xFFFFA257);

  @override
  final primaryDark = Color(0xFFD45400);

  @override
  final primaryLight = Color(0xFFFFD0A3);

  @override
  get splashScreenColor => primaryLight;

  @override
  final onboardingGradientStart = Color(0xFFFF8213);

  @override
  final onboardingGradientEnd = Color(0xFFE94E1B);

  @override
  final Color errorBorderColor = Color(0xFFDA534F).withOpacity(0.32);

  @override
  final Color errorContentColor = Color(0xFF8F0A06);
}

class VoysTheme extends BrandTheme {
  @override
  IconData get logo => VialerSans.brandVoys;

  @override
  final primary = Color(0xFF3B14B9);

  @override
  final primaryDark = Color(0xFF31227A);

  @override
  final primaryLight = Color(0xFFC0B4E8);

  @override
  get splashScreenColor => primary;

  @override
  get onboardingGradientStart => Color(0xFFC0B4E8);

  @override
  get onboardingGradientEnd => primaryDark;

  @override
  final Color errorBorderColor = Color(0xFF2491FF).withOpacity(0.32);

  @override
  Color get errorContentColor => primaryDark;

  @override
  Color get buttonColor => primary;

  @override
  Color get buttonShadeColor => primaryDark;

  @override
  Color get buttonRaisedTextColor => primary;

  @override
  Color get buttonColoredRaisedTextColor => Colors.white;

  @override
  ThemeData get themeData => super.themeData.copyWith(
        appBarTheme: super.themeData.appBarTheme.copyWith(
              color: primary,
              textTheme: TextTheme(
                title: super.themeData.appBarTheme.textTheme.title.copyWith(
                      color: Colors.white,
                    ),
              ),
              iconTheme: IconThemeData(
                color: Colors.white,
              ),
            ),
      );
}

extension BrandThemeContext on BuildContext {
  BrandTheme get brandTheme => BrandTheme.of(this);
}

abstract class VialerSans {
  static const _family = 'VialerSans';

  static const brandVialer = IconData(0xE98A, fontFamily: _family);
  static const brandVoys = IconData(0xE975, fontFamily: _family);
  static const user = IconData(0xE964, fontFamily: _family);
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
  static const missedCall = IconData(0xE923, fontFamily: _family);
  static const speaker = IconData(0xE984, fontFamily: _family);
  static const voicemail = IconData(0xE98B, fontFamily: _family);
  static const mail = IconData(0xE95B, fontFamily: _family);
  static const exclamationMark = IconData(0xE915, fontFamily: _family);
  static const bug = IconData(0xE90D, fontFamily: _family);
  static const userOff = IconData(0xE9A9, fontFamily: _family);
  static const copy = IconData(0xE904, fontFamily: _family);
}

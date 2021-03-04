import 'package:flutter/material.dart';

extension ThemeTargetPlatform on BuildContext {
  bool get isIOS => Theme.of(this).platform == TargetPlatform.iOS;

  bool get isAndroid => Theme.of(this).platform == TargetPlatform.android;
}

abstract class BrandTheme {
  const BrandTheme();

  LinearGradient get onboardingGradient => LinearGradient(
        colors: [
          onboardingGradientStart,
          onboardingGradientEnd,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  LinearGradient get onboardingGradientReversed => LinearGradient(
        colors: onboardingGradient.colors,
        begin: onboardingGradient.end,
        end: onboardingGradient.begin,
      );

  LinearGradient get splashScreenGradient => LinearGradient(
        colors: [splashScreenColor, splashScreenColor],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  IconData get logo;

  Color get primary;

  Color get primaryDark;

  Color get primaryLight;

  /// Color for use when the [primary] color is the background.
  final Color onPrimaryColor = Colors.white;

  final grey1 = const Color(0xFFCCCCCC);
  final grey2 = const Color(0xFFD8D8D8);
  final grey3 = const Color(0xFFE0E0E0);
  final grey4 = const Color(0xFF8F8F8F);
  final grey5 = const Color(0xFF8B95A3);
  final grey6 = const Color(0xFF666666);

  final settingsBackgroundHighlight = const Color(0xFFEFF0F8);

  final green1 = const Color(0xFF28CA42);
  final green2 = const Color(0xFFACF5A6);
  final green3 = const Color(0xFF046614);

  final red1 = const Color(0xFFDA534F);

  Color get splashScreenColor;

  Color get onboardingGradientStart;

  Color get onboardingGradientEnd;

  Color get callGradientStart;

  Color get callGradientEnd;

  /// Color used when a gradient from [callGradientStart] to [callGradientEnd]
  /// is the background.
  Color get onCallGradientColor => onPrimaryColor;

  final Color errorBorderColor = const Color(0x57DA534F);

  final Color errorContentColor = const Color(0xFFDA534F);

  final Color errorBackgroundColor = const Color(0x4D000000);

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
          headline6: TextStyle(
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
}

class VialerTheme extends BrandTheme {
  const VialerTheme();

  @override
  IconData get logo => VialerSans.brandVialer;

  @override
  final primary = const Color(0xFFFFA257);

  @override
  final primaryDark = const Color(0xFFD45400);

  @override
  final primaryLight = const Color(0xFFFFD0A3);

  @override
  get splashScreenColor => primaryLight;

  @override
  final onboardingGradientStart = const Color(0xFFFF8213);

  @override
  final onboardingGradientEnd = const Color(0xFFE94E1B);

  @override
  get callGradientStart => onboardingGradientStart;

  @override
  get callGradientEnd => onboardingGradientEnd;
}

class VoysTheme extends BrandTheme {
  const VoysTheme();

  @override
  IconData get logo => VialerSans.brandVoys;

  @override
  final primary = const Color(0xFF3B14B9);

  @override
  final primaryDark = const Color(0xFF31227A);

  @override
  final primaryLight = const Color(0xFFC0B4E8);

  @override
  get splashScreenColor => primary;

  @override
  get onboardingGradientStart => const Color(0xFFC0B4E8);

  @override
  get onboardingGradientEnd => primaryDark;

  @override
  get callGradientStart => primary;

  @override
  final callGradientEnd = const Color(0xFF7F67D1);

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
                headline6:
                    super.themeData.appBarTheme.textTheme.headline6.copyWith(
                          color: Colors.white,
                        ),
              ),
              iconTheme: const IconThemeData(
                color: Colors.white,
              ),
            ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(primary),
          ),
        ),
      );
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
  static const search = IconData(0xE937, fontFamily: _family);
  static const close = IconData(0xE9A2, fontFamily: _family);
  static const check = IconData(0xE911, fontFamily: _family);
  static const eye = IconData(0xE914, fontFamily: _family);
  static const eyeOff = IconData(0xE9A5, fontFamily: _family);
  static const caretRight = IconData(0xE98D, fontFamily: _family);
  static const caretLeft = IconData(0xE98E, fontFamily: _family);
  static const voipCloud = IconData(0xE902, fontFamily: _family);
  static const refresh = IconData(0xE9A8, fontFamily: _family);
  static const mute = IconData(0xE945, fontFamily: _family);
  static const transfer = IconData(0xE92C, fontFamily: _family);
  static const onHold = IconData(0xE91F, fontFamily: _family);
  static const hangUp = IconData(0xE96B, fontFamily: _family);
  static const star = IconData(0xE940, fontFamily: _family);
  static const starOutline = IconData(0xE93F, fontFamily: _family);
  static const bluetooth = IconData(0xE917, fontFamily: _family);
}

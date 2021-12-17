import 'package:flutter/material.dart' hide Colors;

// We export this so you only need one
// import for accessing `context.brand.theme.colors`.
export '../util/brand.dart';
export 'theme/brand_theme.dart';
export 'theme/vialer_sans.dart';

extension ThemeTargetPlatform on BuildContext {
  bool get isIOS => Theme.of(this).platform == TargetPlatform.iOS;

  bool get isAndroid => Theme.of(this).platform == TargetPlatform.android;
}

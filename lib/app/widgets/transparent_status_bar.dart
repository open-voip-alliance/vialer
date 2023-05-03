import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TransparentStatusBar extends StatelessWidget {
  const TransparentStatusBar({
    required this.child,
    super.key,
    this.brightness = Brightness.dark,
  });

  final Widget child;

  /// Brightness of the status bar (and other system UI overlay elements).
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: brightness,
        statusBarBrightness:
            brightness == Brightness.dark ? Brightness.light : Brightness.dark,
      ),
      child: child,
    );
  }
}

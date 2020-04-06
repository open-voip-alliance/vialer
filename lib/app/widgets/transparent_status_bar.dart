import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TransparentStatusBar extends StatelessWidget {
  final Widget child;

  /// Brightness of the status bar (and other system UI overlay elements).
  final Brightness brightness;

  const TransparentStatusBar({
    Key key,
    @required this.child,
    this.brightness = Brightness.dark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: brightness,
      ),
      child: child,
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:vialer/app/resources/theme.dart';
import 'package:vialer/app/resources/theme/colors.vialer.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

extension ContextExtensions on BuildContext {
  FlutterColors get colors => brand.theme.colors;
}

/// Extension on [BuildContext] that provides a getter to check if the current context has a [KeyboardDismissOnTap] widget as its parent.
extension KeyboardDismissOnTapContext on BuildContext {
  bool get hasKeyboardDismissAsParent =>
      findAncestorWidgetOfExactType<KeyboardDismissOnTap>() != null;
}

import 'package:flutter/cupertino.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:vialer/presentation/resources/theme.dart';
import 'package:vialer/presentation/resources/theme/colors.vialer.dart';

extension ContextExtensions on BuildContext {
  FlutterColors get colors => brand.theme.colors;
}

/// Extension on [BuildContext] that provides a getter to check if the current context has a [KeyboardDismissOnTap] widget as its parent.
extension KeyboardDismissOnTapContext on BuildContext {
  bool get hasKeyboardDismissAsParent =>
      findAncestorWidgetOfExactType<KeyboardDismissOnTap>() != null;
}

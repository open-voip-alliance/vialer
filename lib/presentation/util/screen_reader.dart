import 'package:flutter/material.dart';

extension Accessibility on BuildContext {
  bool get isUsingScreenReader => MediaQuery.of(this).accessibleNavigation;
}

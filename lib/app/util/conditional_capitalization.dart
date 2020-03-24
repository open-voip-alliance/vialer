import 'package:flutter/widgets.dart';
import '../resources/theme.dart';

extension ConditionalCapitalization on String {
  String toUpperCaseIfAndroid(BuildContext context) =>
      context.isAndroid ? toUpperCase() : this;
}

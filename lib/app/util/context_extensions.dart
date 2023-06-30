import 'package:flutter/cupertino.dart';
import 'package:vialer/app/resources/theme.dart';

import '../resources/theme/colors.dart';

extension ContextExtensions on BuildContext {
  Colors get colors => brand.theme.colors;
}

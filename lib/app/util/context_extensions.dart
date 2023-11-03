import 'package:flutter/cupertino.dart';
import 'package:vialer/app/resources/theme.dart';
import 'package:vialer/app/resources/theme/colors.vialer.dart';

extension ContextExtensions on BuildContext {
  FlutterColors get colors => brand.theme.colors;
}

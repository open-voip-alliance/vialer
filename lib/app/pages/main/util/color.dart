import 'package:flutter/material.dart';

import '../../../resources/theme.dart';

Color calculateColorForPhoneNumber(BuildContext context, String phoneNumber) {
  var hsl = HSLColor.fromColor(context.brand.theme.colors.primary);

  const shadesCount = 6;

  final lightness = (hsl.lightness -
          ((phoneNumber.hashCode % shadesCount) - (shadesCount / 2)) * 0.2)
      .clamp(0.2, 0.8)
      .toDouble();

  return hsl.withLightness(lightness).toColor();
}

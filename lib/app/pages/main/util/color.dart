import 'package:flutter/material.dart';

import '../../../util/brand.dart';

Color calculateColorForPhoneNumber(BuildContext context, String phoneNumber) {
  var hsl = HSLColor.fromColor(context.brand.theme.primary);

  const shadesCount = 6;

  final lightness = (hsl.lightness -
          ((phoneNumber.hashCode % shadesCount) - (shadesCount / 2)) * 0.2)
      .clamp(0.2, 0.8)
      .toDouble();

  return hsl.withLightness(lightness).toColor();
}

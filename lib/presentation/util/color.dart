import 'package:flutter/material.dart';

import 'package:vialer/presentation/resources/theme.dart';

Color calculateColorForPhoneNumber(BuildContext context, String phoneNumber) {
  final hsl = HSLColor.fromColor(context.brand.theme.colors.primary);

  const shadesCount = 6;

  final lightness = (hsl.lightness -
          ((phoneNumber.hashCode % shadesCount) - (shadesCount / 2)) * 0.2)
      .clamp(0.2, 0.8);

  return hsl.withLightness(lightness).toColor();
}

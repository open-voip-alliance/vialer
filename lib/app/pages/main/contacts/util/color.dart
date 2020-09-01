import 'package:flutter/material.dart';
import 'package:dartx/dartx.dart';

import '../../util/color.dart';
import '../../../../../domain/entities/contact.dart';

extension ContactColor on Contact {
  Color calculateColor(BuildContext context) => calculateColorForPhoneNumber(
        context,
        phoneNumbers.firstOrNull?.value ?? '0',
      );
}

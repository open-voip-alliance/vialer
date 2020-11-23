import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';

import '../../../../../domain/entities/contact.dart';
import '../../util/color.dart';

extension ContactColor on Contact {
  Color calculateColor(BuildContext context) => calculateColorForPhoneNumber(
        context,
        phoneNumbers.firstOrNull?.value ?? '0',
      );
}

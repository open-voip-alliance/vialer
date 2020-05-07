import 'package:flutter/material.dart';

import '../../util/color.dart';
import '../../../../../domain/entities/contact.dart';

extension ContactColor on Contact {
  Color calculateColor(BuildContext context) => calculateColorForPhoneNumber(
        context,
        phoneNumbers.firstWhere((_) => true, orElse: () => null)?.value ?? '0',
      );
}

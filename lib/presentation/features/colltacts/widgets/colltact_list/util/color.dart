import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:vialer/domain/util/phone_number.dart';

import '../../../../../../../data/models/colltacts/contact.dart';
import '../../../../../../../data/models/colltacts/shared_contacts/shared_contact.dart';
import '../../../../../util/color.dart';

extension ContactColor on Contact {
  Color calculateColor(BuildContext context) => calculateColorForPhoneNumber(
        context,
        phoneNumbers.firstOrNull?.value ?? '0',
      );
}

extension SharedContactColor on SharedContact {
  Color calculateColor(BuildContext context) => calculateColorForPhoneNumber(
        context,
        numberForColor,
      );
}

extension on SharedContact {
  String get numberForColor {
    final number = phoneNumbers.firstOrNull?.phoneNumberFlat;

    if (number == null) return '0';

    if (number.isInternalNumber) return number;

    return number.slice(4);
  }
}

import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';

import '../../../../../../domain/contacts/contact.dart';
import '../../../../../../domain/user_availability/colleagues/colleague.dart';
import '../../../util/color.dart';

extension ContactColor on Contact {
  Color calculateColor(BuildContext context) => calculateColorForPhoneNumber(
        context,
        phoneNumbers.firstOrNull?.value ?? '0',
      );
}

extension ColleagueColor on Colleague {
  Color calculateColor(BuildContext context) => calculateColorForPhoneNumber(
        context,
        number ?? '0',
      );
}

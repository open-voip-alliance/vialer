import 'package:dartx/dartx.dart';

import '../../domain/colltacts/contact.dart';

extension Name on Contact {
  String get displayName {
    final name = chosenName ?? _fullName;
    final companyName = company ?? '';

    return (name.isNotBlank ? name : companyName).trim();
  }

  String get _fullName =>
      [givenName, middleName, familyName].whereNotNull().join(' ');
}

import 'package:dartx/dartx.dart';

import '../../domain/entities/contact.dart';

extension Name on Contact {
  String get displayName => (chosenName ?? _fullName).trim();

  String get _fullName =>
      [givenName, middleName, familyName].whereNotNull().join(' ');
}

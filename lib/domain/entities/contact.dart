import 'dart:typed_data';

import '../../app/util/contact.dart';

import 'item.dart';

class Contact {
  final String? givenName;
  final String? middleName;
  final String? familyName;
  final String? chosenName;
  final Uint8List? avatar;
  final List<Item> phoneNumbers;
  final List<Item> emails;
  final String? identifier;

  const Contact({
    this.givenName,
    this.middleName,
    this.familyName,
    this.chosenName,
    this.avatar,
    this.phoneNumbers = const [],
    this.emails = const [],
    this.identifier,
  });

  @override
  String toString() => phoneNumbers.isEmpty
      ? '$displayName'
      : '$displayName - ${phoneNumbers.join(', ')}';
}

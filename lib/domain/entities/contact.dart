import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import '../../app/util/contact.dart';
import 'item.dart';

class Contact with EquatableMixin {
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

  @override
  List<Object?> get props => [
    // The same contact in two accounts has two different identifiers. So don't
    // add identifier to the props.
    givenName,
    middleName,
    familyName,
    chosenName,
    phoneNumbers,
    emails,
  ];
}

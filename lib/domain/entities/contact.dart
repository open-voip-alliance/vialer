import 'dart:typed_data';

import 'item.dart';

class Contact {
  final String initials;
  final String name;
  final Uint8List? avatar;
  final List<Item> phoneNumbers;
  final List<Item> emails;
  final String? identifier;

  const Contact({
    required this.initials,
    required this.name,
    this.avatar,
    this.phoneNumbers = const [],
    this.emails = const [],
    this.identifier,
  });

  @override
  String toString() =>
      phoneNumbers.isEmpty ? '$name' : '$name - ${phoneNumbers.join(', ')}';
}

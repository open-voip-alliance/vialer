import 'dart:typed_data';

import 'contact.dart';

import 'item.dart';

class T9Contact extends Contact {
  final Item relevantPhoneNumber;

  T9Contact({
    required String initials,
    required String name,
    Uint8List? avatar,
    required this.relevantPhoneNumber,
  }) : super(initials: initials, name: name, avatar: avatar);

  @override
  String toString() => '$name - $relevantPhoneNumber';
}

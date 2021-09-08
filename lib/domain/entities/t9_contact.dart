import 'dart:typed_data';

import 'contact.dart';

import 'item.dart';

class T9Contact extends Contact {
  final Item relevantPhoneNumber;

  T9Contact({
    required String displayName,
    Uint8List? avatar,
    required this.relevantPhoneNumber,
  }) : super(chosenName: displayName, avatar: avatar);

  @override
  String toString() => '$chosenName - $relevantPhoneNumber';
}

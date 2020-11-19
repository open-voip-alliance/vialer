import 'dart:typed_data';

import 'contact.dart';

import 'item.dart';

class T9Contact extends Contact {
  final Item relevantPhoneNumber;

  T9Contact({String name, Uint8List avatar, this.relevantPhoneNumber})
      : super(name: name);

  @override
  String toString() => '$name - $relevantPhoneNumber';
}

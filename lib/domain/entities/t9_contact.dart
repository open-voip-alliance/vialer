import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import 'contact.dart';

import 'item.dart';

class T9Contact extends Contact with EquatableMixin {
  final Item relevantPhoneNumber;

  T9Contact({
    required String displayName,
    Uint8List? avatar,
    required this.relevantPhoneNumber,
  }) : super(chosenName: displayName, avatar: avatar);

  @override
  String toString() => '$chosenName - $relevantPhoneNumber';

  @override
  List<Object?> get props => [
        relevantPhoneNumber.value,
        relevantPhoneNumber.label,
      ];
}

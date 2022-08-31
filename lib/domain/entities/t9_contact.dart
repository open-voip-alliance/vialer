import 'dart:io';

import 'package:equatable/equatable.dart';

import 'contact.dart';
import 'item.dart';

class T9Contact extends Contact with EquatableMixin {
  final Item relevantPhoneNumber;

  T9Contact({
    required String displayName,
    File? avatar,
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

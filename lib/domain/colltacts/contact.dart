import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../call_records/item.dart';

part 'contact.freezed.dart';
part 'contact.g.dart';

@freezed
class Contact with _$Contact {
  const factory Contact({
    required String? givenName,
    required String? middleName,
    required String? familyName,
    required String? chosenName,
    required String? avatarPath,
    required List<Item> phoneNumbers,
    required List<Item> emails,
    required String? identifier,
    required String? company,
  }) = _Contact;

  factory Contact.fromJson(Map<String, dynamic> json) =>
      _$ContactFromJson(json);

  const Contact._();

  File? get avatar => avatarPath != null ? File(avatarPath!) : null;
}

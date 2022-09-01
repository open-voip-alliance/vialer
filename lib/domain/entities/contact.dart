import 'dart:io';

import 'package:json_annotation/json_annotation.dart';

import '../../app/util/contact.dart';
import 'item.dart';

part 'contact.g.dart';

@JsonSerializable()
class Contact {
  final String? givenName;
  final String? middleName;
  final String? familyName;
  final String? chosenName;
  final String? avatarPath;
  final List<Item> phoneNumbers;
  final List<Item> emails;
  final String? identifier;
  final String? company;

  const Contact({
    this.givenName,
    this.middleName,
    this.familyName,
    this.chosenName,
    this.avatarPath,
    this.phoneNumbers = const [],
    this.emails = const [],
    this.identifier,
    this.company,
  });

  @override
  String toString() => phoneNumbers.isEmpty
      ? '$displayName'
      : '$displayName - ${phoneNumbers.join(', ')}';

  File? get avatar => avatarPath != null ? File(avatarPath!) : null;

  factory Contact.fromJson(Map<String, dynamic> json) =>
      _$ContactFromJson(json);

  Map<String, dynamic> toJson() => _$ContactToJson(this);
}

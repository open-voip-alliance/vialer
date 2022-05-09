import 'package:contacts_service/contacts_service.dart';
import 'package:dartx/dartx.dart';
import 'package:fast_contacts/fast_contacts.dart' hide Contact;

import '../../entities/contact.dart' as domain;
import '../mappers/item.dart';
import 'item.dart';

extension ContactMapper on Contact {
  domain.Contact toDomainEntity() {
    return domain.Contact(
      givenName: givenName,
      middleName: middleName,
      familyName: familyName,
      chosenName: displayName,
      avatar: FastContacts.getContactImage(identifier!),
      phoneNumbers:
          phones?.toDomainEntities().distinct().toList(growable: false) ?? [],
      emails: emails?.toDomainEntities().toList(growable: false) ?? [],
      identifier: identifier,
    );
  }
}

extension ContactIterableMapper on Iterable<Contact> {
  Iterable<domain.Contact> toDomainEntities() => map((i) => i.toDomainEntity());
}

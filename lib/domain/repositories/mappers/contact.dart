import 'package:contacts_service/contacts_service.dart';
import 'package:dartx/dartx.dart';
import 'package:fast_contacts/fast_contacts.dart' hide Contact;

import '../../entities/contact.dart' as domain;
import '../mappers/item.dart';
import 'item.dart';

extension ContactMapper on Contact {
  domain.Contact toDomainEntity({
    bool shouldLoadAvatar = true,
  }) {
    return domain.Contact(
      givenName: givenName,
      middleName: middleName,
      familyName: familyName,
      chosenName: displayName,
      avatar:
          shouldLoadAvatar ? FastContacts.getContactImage(identifier!) : null,
      phoneNumbers:
          phones?.toDomainEntities().distinct().toList(growable: false) ?? [],
      emails: emails?.toDomainEntities().toList(growable: false) ?? [],
      identifier: identifier,
      company: company,
    );
  }
}

extension ContactIterableMapper on Iterable<Contact> {
  Iterable<domain.Contact> toDomainEntities({
    bool shouldLoadAvatar = true,
  }) =>
      map(
        (i) => i.toDomainEntity(
          shouldLoadAvatar: shouldLoadAvatar,
        ),
      );
}

import 'package:contacts_service/contacts_service.dart';

import '../../domain/entities/contact.dart' as domain;

import 'item.dart';

extension ContactMapper on Contact {
  domain.Contact toDomainEntity() {
    return domain.Contact(
      initials: initials(),
      name: displayName ?? '$givenName $middleName $familyName',
      avatar: avatar,
      phoneNumbers: phones.toDomainEntities().toList(growable: false),
      emails: emails.toDomainEntities().toList(growable: false),
    );
  }
}

extension ContactIterableMapper on Iterable<Contact> {
  Iterable<domain.Contact> toDomainEntities() => map((i) => i.toDomainEntity());
}

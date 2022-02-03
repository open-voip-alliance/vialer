import 'package:contacts_service/contacts_service.dart' hide Contact;
import 'package:dartx/dartx.dart';

import '../entities/contact.dart';
import 'mappers/contact.dart';

class ContactRepository {
  Future<List<Contact>> getContacts({
    bool onlyWithPhoneNumber = true,
  }) async {
    final contacts = await ContactsService.getContacts(
      withThumbnails: false,
      photoHighResolution: false,
    ).then((contacts) => contacts.toDomainEntities());

    return contacts
        .filterHasPhoneNumber(applyWhen: onlyWithPhoneNumber)
        .toList(growable: false);
  }

  Future<Contact?> getContactByPhoneNumber(String number) async =>
      await ContactsService.getContactsForPhone(
        number,
        withThumbnails: false,
        photoHighResolution: false,
      ).then(
        (contacts) => contacts.firstOrNull?.toDomainEntity(),
      );
}

extension on Iterable<Contact> {
  Iterable<Contact> filterHasPhoneNumber({
    bool applyWhen = true,
  }) =>
      applyWhen ? where((contact) => contact.phoneNumbers.isNotEmpty) : this;
}

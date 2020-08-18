import 'package:contacts_service/contacts_service.dart' hide Contact;

import '../entities/contact.dart';

import 'mappers/contact.dart';

class ContactRepository {
  Future<List<Contact>> getContacts() async {
    final contacts = await ContactsService.getContacts(
      withThumbnails: false,
      photoHighResolution: false,
    ).then((contacts) => contacts.toDomainEntities());

    return contacts.toList(growable: false);
  }
}

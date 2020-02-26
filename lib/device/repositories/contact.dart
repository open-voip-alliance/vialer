import 'package:contacts_service/contacts_service.dart' hide Contact;

import '../../domain/entities/contact.dart';
import '../../domain/repositories/contact.dart';

import '../mappers/contact.dart';

class DeviceContactsRepository extends ContactRepository {
  @override
  Future<List<Contact>> getContacts() async {
    final contacts = await ContactsService.getContacts(
      withThumbnails: false,
      photoHighResolution: false,
    ).then((contacts) => contacts.toDomainEntities());

    return contacts.toList(growable: false);
  }
}

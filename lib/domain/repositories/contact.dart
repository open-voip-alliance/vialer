import 'package:contacts_service/contacts_service.dart' hide Contact;
import 'package:dartx/dartx.dart';

import '../../dependency_locator.dart';
import '../entities/contact.dart';
import 'mappers/contact.dart';
import 'metrics.dart';

class ContactRepository {
  /// The number of contacts after which we will no longer load avatars, this is
  /// for performance reasons.
  static const maximumContactsForAvatarLoading = 500;

  final _metrics = dependencyLocator<MetricsRepository>();

  Future<List<Contact>> getContacts({
    bool onlyWithPhoneNumber = true,
  }) async {
    final contacts = await ContactsService.getContacts(
      withThumbnails: false,
      photoHighResolution: false,
    ).then(
      (contacts) => contacts.toDomainEntities(
        shouldLoadAvatar: contacts.length <= maximumContactsForAvatarLoading,
      ),
    );

    _metrics.track('contacts-loaded', {
      'amount': contacts.length,
    });

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

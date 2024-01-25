import 'package:injectable/injectable.dart';
import 'package:vialer/data/models/colltacts/shared_contacts/shared_contact.dart';

import '../../repositories/colltacts/contact_repository.dart';
import '../../repositories/legacy/storage.dart';
import '../call_records/call_record.dart';
import '../call_records/item.dart';
import 'contact.dart';

@singleton
class CallRecordContactPopulator {
  const CallRecordContactPopulator(
    this._contactsRepository,
    this._storageRepository,
  );

  final ContactRepository _contactsRepository;
  final StorageRepository _storageRepository;

  Future<List<CallRecordWithContact>> populate(
    List<CallRecord> callRecords,
  ) async {
    final contacts = await _getContactPhoneNumberMap();
    final sharedContacts = await _getSharedContactPhoneNumberMap();

    return callRecords.map((call) {
      final contact = contacts.findForVariations(call.lookupVariations) ??
          sharedContacts.findForVariations(call.lookupVariations);

      return call.withContact(contact);
    }).toList();
  }

  Future<List<ClientCallRecordWithContact>> populateForClientCalls(
    List<ClientCallRecord> callRecords,
  ) async {
    final contacts = await _getContactPhoneNumberMap();
    final sharedContacts = await _getSharedContactPhoneNumberMap();

    return callRecords.map(
      (call) {
        final callerVariations = call.createVariations(call.caller.number);
        final destinationVariations = call.createVariations(
          call.destination.number,
        );

        final caller = contacts.findForVariations(callerVariations) ??
            sharedContacts.findForVariations(callerVariations);
        final destination = contacts.findForVariations(destinationVariations) ??
            sharedContacts.findForVariations(destinationVariations);

        return call.withContact(
          callerContact: caller,
          destinationContact: destination,
        );
      },
    ).toList();
  }

  /// Retrieve a mapping between a phone number and a contact, this allows for
  /// optimized look-up of contacts.
  Future<Map<String, Contact>> _getContactPhoneNumberMap() async {
    final contacts = await _contactsRepository.getContacts();
    final map = <String, Contact>{};

    for (final contact in contacts) {
      for (final item in contact.phoneNumbers) {
        final phoneNumber = item.value;
        map[phoneNumber.replaceAll(' ', '')] = contact;

        // Most contacts format numbers with country codes to
        // e.g. +31 6 4....
        // So we will replace the first item with a 0 to match with
        // non-country code phone numbers.
        final split = item.value.split(' ');

        if (split.length > 1) {
          split[0] = '0';
          map[split.join()] = contact;
        }
      }
    }

    return map;
  }

  Future<Map<String, Contact>> _getSharedContactPhoneNumberMap() async {
    final contacts = await _storageRepository.sharedContacts;
    final map = <String, Contact>{};

    for (final sharedContact in contacts) {
      for (final item in sharedContact.phoneNumbers) {
        final contact = sharedContact.toContact();

        map[item.phoneNumberFlat] = contact;
        map[item.withoutCallingCode] = contact;
      }
    }

    return map;
  }
}

extension on Map<String, Contact> {
  Contact? findForVariations(List<String> variations) {
    for (final number in variations) {
      final contact = this[number];

      if (contact != null) {
        return contact;
      }
    }

    return null;
  }
}

extension on SharedContact {
  Contact toContact() => Contact(
        givenName: givenName,
        middleName: '',
        familyName: familyName,
        chosenName: displayName,
        avatarPath: null,
        phoneNumbers: phoneNumbers
            .map(
              (e) => Item(
                label: '',
                value: e.phoneNumberFlat,
              ),
            )
            .toList(),
        emails: [],
        identifier: id,
        company: companyName,
      );
}

extension on CallRecord {
  String get numberForContactLookup =>
      isOutbound ? destination.number : caller.number;

  /// Creates a prioritized list of numbers to perform a look-up with in
  /// contacts, this is mainly a simple way to remove the country code
  /// without introducing any complicated/slow phone number parsing.
  List<String> get lookupVariations {
    return createVariations(numberForContactLookup);
  }

  List<String> createVariations(String number) {
    if (number.length <= 5) return [number];

    return [
      number,
      number.replaceRange(0, 3, '0'),
      number.replaceRange(0, 2, '0'),
      number.replaceRange(0, 1, '0'),
      number.replaceRange(0, 4, '0'),
    ];
  }
}

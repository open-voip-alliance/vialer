import '../dependency_locator.dart';
import 'entities/call_record.dart';
import 'entities/call_record_with_contact.dart';
import 'entities/contact.dart';
import 'repositories/contact.dart';

class CallRecordContactPopulator {
  final _contactsRepository = dependencyLocator<ContactRepository>();

  Future<List<CallRecordWithContact>> populate(
    List<CallRecord> callRecords,
  ) async {
    final contacts = await getContactPhoneNumberMap();

    return callRecords.map(
      (call) {
        for (final number in call.lookupVariations) {
          final contact = contacts[number];

          if (contact != null) {
            return call.withContact(contact);
          }
        }

        return call.withContact(null);
      },
    ).toList();
  }

  /// Retrieve a mapping between a phone number and a contact, this allows for
  /// optimized look-up of contacts.
  Future<Map<String, Contact>> getContactPhoneNumberMap() async {
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
}

extension on CallRecord {
  String get numberForContactLookup =>
      isOutbound ? destination.number : caller.number;

  /// Creates a prioritized list of numbers to perform a look-up with in
  /// contacts, this is mainly a simple way to remove the country code
  /// without introducing any complicated/slow phone number parsing.
  List<String> get lookupVariations {
    final number = numberForContactLookup;

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

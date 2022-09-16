import '../dependency_locator.dart';
import 'entities/call_record.dart';
import 'entities/call_record_with_contact.dart';
import 'repositories/contact.dart';

class CallRecordContactPopulator {
  final _contactsRepository = dependencyLocator<ContactRepository>();

  Future<List<CallRecordWithContact>> populate(
    List<CallRecord> callRecords,
  ) async {
    final contacts = await _contactsRepository.getContactPhoneNumberMap();

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

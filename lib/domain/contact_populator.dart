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

    return callRecords
        .map(
          (call) => call.withContact(contacts[call.numberForContactLookup]),
        )
        .toList();
  }
}

extension on CallRecord {
  String get numberForContactLookup =>
      isOutbound ? destination.number : caller.number;
}

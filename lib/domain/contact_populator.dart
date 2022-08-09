import 'package:dartx/dartx.dart';

import 'entities/call_record.dart';
import 'entities/call_record_with_contact.dart';
import 'entities/contact.dart';
import 'usecases/get_contact.dart';

class CallRecordContactPopulator {
  late final _getContact = GetContactUseCase();

  Future<List<CallRecordWithContact>> populate(
    List<CallRecord> callRecords,
  ) async {
    final foundContacts = <String, Contact>{};

    final uniqueNumbers =
        callRecords.map((e) => e.numberForContactLookup).distinct();

    for (final number in uniqueNumbers) {
      final contact = await _getContact(number: number);

      if (contact != null) {
        foundContacts[number] = contact;
      }
    }

    return callRecords
        .map(
          (call) => call.withContact(
            foundContacts[call.numberForContactLookup],
          ),
        )
        .toList();
  }
}

extension on CallRecord {
  String get numberForContactLookup =>
      isOutbound ? destination.number : caller.number;
}

import 'package:dartx/dartx.dart';
import 'package:libphonenumber/libphonenumber.dart';

import '../../app/util/loggable.dart';

import '../../data/mappers/call_record.dart';
import '../../data/models/voipgrid_call_record.dart';
import '../entities/call_record.dart';
import '../entities/call_record_with_contact.dart';
import '../entities/contact.dart';

import 'services/voipgrid.dart';

class RecentCallRepository with Loggable {
  final VoipgridService _service;

  RecentCallRepository(
    this._service,
  );

  Future<List<CallRecordWithContact>> getRecentCalls({
    required int page,
    required String outgoingNumber,
    Iterable<Contact> contacts = const [],
  }) async {
    var calls = <CallRecord>[];

    logger.info(
      'Fetching recent calls page: $page',
    );

    if (calls.isEmpty) {
      logger.info('None cached, request more via API');
      final response = await _service.getPersonalCalls(
        pageNumber: page,
      );

      final objects = response.body as List<dynamic>? ?? [];

      if (objects.isNotEmpty) {
        calls = objects
            .map((jsonObject) =>
                VoipgridCallRecord.fromJson(jsonObject as Map<String, dynamic>)
                    .toCallRecord())
            .toList();
      }
    }

    Future<String?> normalizeNumber(String number) async => number.length > 3
        ? await PhoneNumberUtil.normalizePhoneNumber(
            phoneNumber: number,
            // TODO: Temporary fix. Preferably we'd could pass a prefix
            // directly and have another method that fetches the prefix from the
            // outgoingCli (although that isn't _too_ complicated), or we need
            // to map  all prefixes against two-letter ISO country codes and
            // pass that.
            isoCode: outgoingNumber.startsWith('+31') ? 'NL' : 'DE',
          ).catchError((_) => null)
        : number;

    // Map phone numbers by contact.
    final phoneNumbersByContact = Map.fromEntries(
      await Future.wait(
        contacts.map(
          (contact) async => MapEntry(
            contact,
            await Future.wait(
              contact.phoneNumbers
                  .map((phoneNumber) => normalizeNumber(phoneNumber.value))
                  .toList(),
            ),
          ),
        ),
      ),
    );

    final normalizedCalls = await Future.wait(
      calls.map(
        (c) async => c.copyWith(
          destinationNumber:
              c.isOutbound ? await normalizeNumber(c.destinationNumber) : null,
          callerNumber:
              c.isInbound ? await normalizeNumber(c.callerNumber) : null,
        ),
      ),
    );

    logger.info('Mapping calls to contacts');
    return calls
        .map(
          (call) => call.withContact(
            phoneNumbersByContact.entries.firstOrNullWhere((entry) {
              final normalizedCall = normalizedCalls.firstOrNullWhere(
                (normalizedCall) => normalizedCall.id == call.id,
              );

              if (normalizedCall == null) {
                return false;
              }

              final numbers = entry.value;

              final relevantCallNumber = normalizedCall.isOutbound
                  ? normalizedCall.destinationNumber
                  : normalizedCall.callerNumber;

              return numbers.contains(relevantCallNumber);
            })?.key, // The contact.
          ),
        )
        .toList();
  }
}

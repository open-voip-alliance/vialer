import 'package:dartx/dartx.dart';
import 'package:libphonenumber/libphonenumber.dart';

import '../../app/util/loggable.dart';

import '../../data/mappers/call_record.dart';
import '../../data/models/voipgrid_call_record.dart';
import '../entities/call_record.dart';
import '../entities/call_record_with_contact.dart';
import '../entities/contact.dart';

import 'db/database.dart';
import 'services/voipgrid.dart';

class RecentCallRepository with Loggable {
  final VoipgridService _service;
  final Database _database;

  RecentCallRepository(
    this._service,
    this._database,
  );

  final _daysPerPage = 28;
  // int _cacheStartPage;

  Future<List<CallRecordWithContact>> getRecentCalls({
    required int page,
    required String outgoingNumber,
    Iterable<Contact> contacts = const [],
  }) async {
    final today = DateTime.now().add(const Duration(days: 1));
    final fromUtc = today
        .subtract(
          Duration(days: _daysPerPage * (page + 1)),
        )
        .toUtc();
    final toUtc = today
        .subtract(
          Duration(days: _daysPerPage * page),
        )
        .toUtc();

    var calls = <CallRecord>[];

    logger.info(
      'Fetching recent calls between: '
      '${toUtc.toIso8601String()} and ${fromUtc.toIso8601String()}',
    );

    // Never get from cache for the first page, and then only
    // from when we're sure there's nothing remote.
    // if (page != 0 && page >= (_cacheStartPage ?? 0)) {
    //   calls = await _database.getCalls(from: fromUtc, to: toUtc);
    //   logger.info('Amount of calls from cache: ${calls.length}');
    // }

    if (calls.isEmpty) {
      logger.info('None cached, request more via API');
      final response = await _service.getPersonalCalls(
        pageNumber: page,
      );

      final objects = response.body['objects'] as List<dynamic>? ?? [];

      if (objects.isNotEmpty) {
        calls = objects
            .map((obj) =>
                VoipgridCallRecord.fromJson(obj as Map<String, dynamic>))
            // .map(
            //   (c) => c.copyWith(
            //     // The wrapper is needed so that it's a normal
            //     // DateTime and not a TZDateTime, because we want to call
            //     // the DateTime.toLocal method, not TZDateTime.toLocal, because
            //     // the latter uses the location set with `setLocation`, which
            //     // we can't use because we can't get the current time zone
            //     // automatically, but DateTime.toLocal _will_ convert it to the
            //     // correct current time zone.
            //     date: DateTime.fromMillisecondsSinceEpoch(
            //       TZDateTime.from(
            //         c.date,
            //         getLocation('Europe/Amsterdam'),
            //       ).millisecondsSinceEpoch,
            //       isUtc: true,
            //     ),
            //   ),
            // )
            .map(
              (voipgridCallRecord) => voipgridCallRecord.toCallRecord(),
            )
            .toList();

        final mostRecentCall = await _database.getMostRecentCall();
        if (calls.any((c) => c.id == mostRecentCall.id)) {
          // If the response contains the most recent call we got, we can
          // continue from cache.
          // _cacheStartPage = page;
        }

        logger.info('Amount of calls from request: ${calls.length}');
        _database.insertCalls(calls);
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

import 'package:libphonenumber/libphonenumber.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:timezone/timezone.dart';

import 'db/moor.dart';
import 'services/voipgrid.dart';

import '../../domain/entities/call.dart';

import '../../domain/repositories/recent_call.dart';
import '../../domain/repositories/contact.dart';

class DataRecentCallRepository extends RecentCallRepository {
  final VoipgridService _service;
  final Database _database;
  final ContactRepository _contactRepository;

  DataRecentCallRepository(
    this._service,
    this._database,
    this._contactRepository,
  );

  Logger __logger;

  Logger get _logger => __logger ??= Logger('@$runtimeType');

  final _daysPerPage = 28;
  int _cacheStartPage;

  @override
  Future<List<Call>> getRecentCalls({@required int page}) async {
    final today = DateTime.now().add(Duration(days: 1));
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

    var calls = <Call>[];

    _logger.info(
      'Fetching recent calls between: '
      '${toUtc.toIso8601String()} and ${fromUtc.toIso8601String()}',
    );

    // Never get from cache for the first page, and then only
    // from when we're sure there's nothing remote.
    if (page != 0 && page >= (_cacheStartPage ?? 0)) {
      calls = await _database.getCalls(from: fromUtc, to: toUtc);
      _logger.info('Amount of calls from cache: ${calls.length}');
    }

    if (calls.isEmpty) {
      _logger.info('None cached, request more via API');
      final response = await _service.getPersonalCalls(
        from: fromUtc.toIso8601String(),
        to: toUtc.toIso8601String(),
      );

      final objects = response.body['objects'] as List<dynamic> ?? [];

      if (objects.isNotEmpty) {
        calls = objects
            .map((obj) => Call.fromJson(obj))
            .map(
              (c) => c.copyWith(
                // The wrapper is needed so that it's a normal
                // DateTime and not a TZDateTime, because we want to call
                // the DateTime.toLocal method, not TZDateTime.toLocal, because
                // the latter uses the location set with `setLocation`, which
                // we can't use because we can't get the current time zone
                // automatically, but DateTime.toLocal _will_ convert it to the
                // correct current time zone.
                date: DateTime.fromMillisecondsSinceEpoch(
                  TZDateTime.from(
                    c.date,
                    getLocation('Europe/Amsterdam'),
                  ).millisecondsSinceEpoch,
                  isUtc: true,
                ),
              ),
            )
            .toList();

        final mostRecentCall = await _database.getMostRecentCall();
        if (mostRecentCall != null &&
            calls.any((c) => c.id == mostRecentCall.id)) {
          // If the response contains the most recent call we got, we can
          // continue from cache.
          _cacheStartPage = page;
        }

        _logger.info('Amount of calls from request: ${calls.length}');
        _database.insertCalls(calls);
      }
    }

    final contacts = await _contactRepository.getContacts();

    // Create a list with all phone numbers of the recent calls
    // respecting the call direction.
    var phoneNumbers = calls.map(
      (call) => call.direction == Direction.outbound
          ? call.destinationNumber
          : call.callerNumber,
    );

    // Add all the phone numbers from the contacts.
    phoneNumbers = phoneNumbers.followedBy(
      contacts
          .map(
            (contact) =>
                contact.phoneNumbers.map((phoneNumber) => phoneNumber.value),
          )
          .expand((pair) => pair),
    );

    // Remove duplicate phone numbers.
    phoneNumbers = phoneNumbers.toSet().toList();

    final normalizedPhoneNumbers = await Future.wait(
      phoneNumbers.map(
        (phoneNumber) => PhoneNumberUtil.normalizePhoneNumber(
          phoneNumber: phoneNumber,
          isoCode: 'NL',
        ).catchError((_) => null),
      ),
    );

    // Create a mapping from the original to the normalized phone number.
    final mappedPhoneNumbers = phoneNumbers.toList().asMap().map(
          (index, phoneNumber) => MapEntry(
            phoneNumber,
            normalizedPhoneNumbers[index],
          ),
        );

    // Remove the phone numbers for which the normalization threw an error.
    mappedPhoneNumbers.removeWhere((_, value) => value == null);

    _logger.info('Mapping calls to contacts and correct local time');
    calls = calls
        .map(
          (call) => call.copyWith(
            destinationContactName: contacts
                .firstWhere(
                  (contact) => contact.phoneNumbers.any(
                    (i) =>
                        mappedPhoneNumbers[i.value] ==
                        mappedPhoneNumbers[call.direction == Direction.outbound
                            ? call.destinationNumber
                            : call.callerNumber],
                  ),
                  orElse: () => null,
                )
                ?.name,
            localDate: call.date.toLocal(),
          ),
        )
        .toList();

    return calls;
  }
}

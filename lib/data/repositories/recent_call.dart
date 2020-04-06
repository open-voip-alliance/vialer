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

  int _cacheStartPage;

  @override
  Future<List<Call>> getRecentCalls({@required int page}) async {
    const days = 30;
    final to = DateTime.now().subtract(Duration(days: days * page));

    var calls = <Call>[];
    final from = to.subtract(Duration(days: days));

    _logger.info(
      'Fetching recent calls between: '
      '${to.toIso8601String()} and ${from.toIso8601String()}',
    );

    // Never get from cache for the first page, and then only
    // from when we're sure there's nothing remote
    if (page != 0 && page >= (_cacheStartPage ?? 0)) {
      calls = await _database.getCalls(from: from, to: to);
      _logger.info('Amount of calls from cache: ${calls.length}');
    }

    if (calls.isEmpty) {
      _logger.info('None cached, request more via API');
      final response = await _service.getPersonalCalls(
        from: from.toIso8601String(),
        to: to.toIso8601String(),
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
                // we can't use becauise we can't get the current time zone
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
          // continue from cache
          _cacheStartPage = page;
        }

        _logger.info('Amount of calls from request: ${calls.length}');
        _database.insertCalls(calls);
      }
    }

    final contacts = await _contactRepository.getContacts();

    _logger.info('Mapping calls to contacts and correct local time');
    calls = calls
        .map(
          (call) => call.copyWith(
            destinationContactName: contacts
                .firstWhere(
                  (contact) => contact.phoneNumbers.any(
                    // TODO: Proper normalization before equality check
                    (i) =>
                        i.value.replaceAll(' ', '') ==
                        call.destinationNumber.replaceAll(' ', ''),
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

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

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

    calls = await _database.getCalls(from: from, to: to);
    _logger.info('Amount of calls from cache: ${calls.length}');
    if (calls.isEmpty) {
      _logger.info('None cached, request more via API');
      final response = await _service.getPersonalCalls(
        from: from.toIso8601String(),
        to: to.toIso8601String(),
      );

      final objects = response.body['objects'] as List<dynamic> ?? [];

      if (objects.isNotEmpty) {
        calls = objects.map((obj) => Call.fromJson(obj)).toList();
        _logger.info('Amount of calls from request: ${calls.length}');
        _database.insertCalls(calls);
      }
    }

    final contacts = await _contactRepository.getContacts();

    _logger.info('Mapping calls to contacts');
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
          ),
        )
        .toList();

    return calls;
  }
}

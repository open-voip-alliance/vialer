import 'package:dartx/dartx.dart';

import '../../../app/util/loggable.dart';
import '../../../data/mappers/call_record.dart';
import '../../../data/models/voipgrid_call_record.dart';
import '../../colltacts/contact.dart' as domain;
import '../../voipgrid/voipgrid_service.dart';
import '../call_record.dart';

class RecentCallRepository with Loggable {
  final VoipgridService _service;

  RecentCallRepository(
    this._service,
  );

  /// [page] starts at 1.
  Future<List<CallRecord>> getRecentCalls({
    required int page,
    bool onlyMissedCalls = false,
    Iterable<domain.Contact> contacts = const [],
  }) async {
    assert(page > 0);
    logger.info(
      'Fetching recent ${onlyMissedCalls ? 'missed' : 'all'} calls page: $page',
    );

    final response = await _service.getPersonalCalls(
      pageNumber: page,
      answered: onlyMissedCalls ? false : null,
    );

    final objects = response.body as List<dynamic>? ?? [];

    if (objects.isEmpty) {
      return <CallRecord>[];
    } else {
      var callRecords = objects.map(
        (jsonObject) => VoipgridCallRecord.fromJson(
          jsonObject as Map<String, dynamic>,
        ).toCallRecord(),
      );

      // Restrict the missed calls only to incoming ones.
      if (onlyMissedCalls) {
        callRecords = callRecords.filter((contact) => contact.isInbound);
      }

      return callRecords.toList();
    }
  }
}

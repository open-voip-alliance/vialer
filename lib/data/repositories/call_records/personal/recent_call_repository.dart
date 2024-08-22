import 'package:dartx/dartx.dart';
import 'package:injectable/injectable.dart';

import '../../../../presentation/util/loggable.dart';
import '../../../API/voipgrid/voipgrid_service.dart';
import '../../../models/call_records/call_record.dart';
import '../../../models/call_records/mappers/call_record.dart';
import '../../../models/call_records/voipgrid_call_record.dart';
import '../../../models/colltacts/contact.dart' as domain;

@singleton
class RecentCallRepository with Loggable {
  RecentCallRepository(
    this._service,
  );

  final VoipgridService _service;

  /// [page] starts at 1.
  Future<List<CallRecord>> getRecentCalls({
    required int page,
    bool onlyMissedCalls = false,
    Iterable<domain.Contact> contacts = const [],
  }) async {
    assert(page > 0, 'page starts at 1');
    logger.info(
      'Fetching recent ${onlyMissedCalls ? 'missed' : 'all'} calls page: $page',
    );

    final response = await _service.getPersonalCalls(
      pageNumber: page,
      answered: onlyMissedCalls ? false : null,
    );

    final objects = response.body ?? const [];

    if (objects.isEmpty) return const [];

    var callRecords = objects.map(
      (dynamic jsonObject) => VoipgridCallRecord.fromJson(
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

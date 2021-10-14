import '../../app/util/loggable.dart';
import '../../data/mappers/call_record.dart';
import '../../data/models/voipgrid_call_record.dart';
import '../entities/call_record.dart';
import '../entities/contact.dart' as domain;
import 'services/voipgrid.dart';

class RecentCallRepository with Loggable {
  final VoipgridService _service;

  RecentCallRepository(
    this._service,
  );

  /// [page] starts at 1.
  Future<List<CallRecord>> getRecentCalls({
    required int page,
    required String outgoingNumber,
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

    return objects.isNotEmpty
        ? objects
            .map(
              (jsonObject) => VoipgridCallRecord.fromJson(
                jsonObject as Map<String, dynamic>,
              ).toCallRecord(),
            )
            .toList()
        : <CallRecord>[];
  }
}

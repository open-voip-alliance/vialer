import 'dart:core';

import '../../../../data/models/call_records/call_record.dart';
import '../../../../data/models/colltacts/contact_populator.dart';
import '../../../../data/repositories/call_records/personal/recent_call_repository.dart';
import '../../../../dependency_locator.dart';
import '../../use_case.dart';

class GetRecentCallsUseCase extends UseCase {
  final _recentCallRepository = dependencyLocator<RecentCallRepository>();
  final _callRecordContactPopulator =
      dependencyLocator<CallRecordContactPopulator>();

  /// [page] starts at 1.
  Future<List<CallRecordWithContact>> call({
    required int page,
    bool onlyMissedCalls = false,
  }) async {
    assert(page > 0, 'page starts at 1');

    final callRecords = await _recentCallRepository.getRecentCalls(
      page: page,
      onlyMissedCalls: onlyMissedCalls,
    );

    return _callRecordContactPopulator.populate(callRecords);
  }
}

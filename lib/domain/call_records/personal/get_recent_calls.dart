import 'dart:core';

import '../../../dependency_locator.dart';
import '../../contacts/contact_populator.dart';
import '../../use_case.dart';
import '../call_record_with_contact.dart';
import 'recent_call_repository.dart';

class GetRecentCallsUseCase extends UseCase {
  final _recentCallRepository = dependencyLocator<RecentCallRepository>();
  final _callRecordContactPopulator =
      dependencyLocator<CallRecordContactPopulator>();

  /// [page] starts at 1.
  Future<List<CallRecordWithContact>> call({
    required int page,
    bool onlyMissedCalls = false,
  }) async {
    assert(page > 0);

    final callRecords = await _recentCallRepository.getRecentCalls(
      page: page,
      onlyMissedCalls: onlyMissedCalls,
    );

    return _callRecordContactPopulator.populate(callRecords);
  }
}

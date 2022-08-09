import 'dart:core';


import '../../dependency_locator.dart';
import '../contact_populator.dart';
import '../entities/call_record_with_contact.dart';
import '../repositories/recent_call.dart';
import '../use_case.dart';
import 'get_user.dart';

class GetRecentCallsUseCase extends UseCase {
  final _recentCallRepository = dependencyLocator<RecentCallRepository>();
  final _callRecordContactPopulator =
      dependencyLocator<CallRecordContactPopulator>();

  final _getUser = GetUserUseCase();

  /// [page] starts at 1.
  Future<List<CallRecordWithContact>> call({
    required int page,
    bool onlyMissedCalls = false,
  }) async {
    assert(page > 0);
    final user = await _getUser(latest: false);

    final callRecords = await _recentCallRepository.getRecentCalls(
      page: page,
      outgoingNumber: user!.outgoingCli!,
      onlyMissedCalls: onlyMissedCalls,
    );

    return _callRecordContactPopulator.populate(callRecords);
  }
}

import 'dart:core';

import '../../dependency_locator.dart';
import '../contact_populator.dart';
import '../entities/call_record_with_contact.dart';
import '../repositories/local_client_calls.dart';
import '../use_case.dart';

class GetRecentClientCallsUseCase extends UseCase {
  final _clientCalls = dependencyLocator<LocalClientCallsRepository>();
  final _callRecordContactPopulator =
      dependencyLocator<CallRecordContactPopulator>();

  static const _perPage = 20;

  /// [page] starts at 1 to maintain consistency with [GetRecentCalls].
  Future<List<CallRecordWithContact>> call({
    int page = 1,
    bool onlyMissedCalls = false,
  }) async {
    final records = await _clientCalls.getCalls(
      page: page,
      perPage: _perPage,
      onlyMissedCalls: onlyMissedCalls,
    );

    return _callRecordContactPopulator.populate(records);
  }
}

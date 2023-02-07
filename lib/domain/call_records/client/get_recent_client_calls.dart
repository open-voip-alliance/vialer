import 'dart:core';

import '../../../dependency_locator.dart';
import '../../use_case.dart';
import '../call_record.dart';
import 'local_client_calls.dart';

class GetRecentClientCallsUseCase extends UseCase {
  final _clientCalls = dependencyLocator<LocalClientCallsRepository>();

  static const _perPage = 50;

  /// [page] starts at 1 to maintain consistency with [GetRecentCalls].
  Future<List<ClientCallRecord>> call({
    int page = 1,
    bool onlyMissedCalls = false,
  }) async =>
      await _clientCalls.getCalls(
        page: page,
        perPage: _perPage,
        onlyMissedCalls: onlyMissedCalls,
      );
}

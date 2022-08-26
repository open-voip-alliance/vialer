import 'dart:core';

import '../../dependency_locator.dart';
import '../entities/client_call_record.dart';
import '../repositories/local_client_calls.dart';
import '../use_case.dart';

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

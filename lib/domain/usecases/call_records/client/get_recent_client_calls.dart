import 'dart:core';

import 'package:injectable/injectable.dart';

import '../../../../data/models/call_records/call_record.dart';
import '../../../../data/models/colltacts/contact_populator.dart';
import '../../../../data/repositories/call_records/client/local_client_calls.dart';
import '../../use_case.dart';
import '../personal/get_recent_calls.dart';

@injectable
class GetRecentClientCallsUseCase extends UseCase {
  GetRecentClientCallsUseCase(this._clientCalls, this._populator);

  final LocalClientCallsRepository _clientCalls;
  final CallRecordContactPopulator _populator;

  static const _perPage = 50;

  /// [page] starts at 1 to maintain consistency with [GetRecentCallsUseCase].
  Future<List<ClientCallRecordWithContact>> call({
    int page = 1,
    bool onlyMissedCalls = false,
  }) =>
      _clientCalls
          .getCalls(
            page: page,
            perPage: _perPage,
            onlyMissedCalls: onlyMissedCalls,
          )
          .then((calls) => _populator.populateForClientCalls(calls));
}

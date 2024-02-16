import 'dart:async';

import '../../../../../data/repositories/metrics/metrics.dart';
import '../../../../../dependency_locator.dart';
import '../../../../data/models/calling/call_through/call_through_exception.dart';
import '../../../../data/repositories/calling/call_through/call_through.dart';
import '../../../../data/repositories/legacy/memory_storage_repository.dart';
import '../../use_case.dart';
import '../../user/get_logged_in_user.dart';

class GetCallThroughRegionNumberUseCase extends UseCase {
  final _memoryStorageRepository = dependencyLocator<MemoryStorageRepository>();
  final _callThroughRepository = dependencyLocator<CallThroughRepository>();
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  final _getUser = GetLoggedInUserUseCase();

  Future<String?> call({
    required String destination,
  }) async {
    var regionNumber = _memoryStorageRepository.regionNumber;

    if (regionNumber == null) {
      try {
        regionNumber = await _callThroughRepository.retrieveRegionNumber(
          destination,
          user: _getUser(),
        );
      } on CallThroughException catch (e) {
        _metricsRepository.track(
          'call-through-region-number-retrieval-failed',
          {
            'error': e.runtimeType.toString(),
          },
        );
        rethrow;
      }

      _memoryStorageRepository.regionNumber = regionNumber;
    }

    return regionNumber;
  }
}

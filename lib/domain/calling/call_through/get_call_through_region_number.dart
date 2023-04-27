import 'dart:async';

import '../../../../dependency_locator.dart';
import '../../legacy/memory_storage_repository.dart';
import '../../metrics/metrics.dart';
import '../../use_case.dart';
import '../../user/get_logged_in_user.dart';
import 'call_through.dart';
import 'call_through_exception.dart';

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
          'call-through-region-number-failed',
          <String, dynamic>{
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

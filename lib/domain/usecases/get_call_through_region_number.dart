import 'dart:async';

import '../../../dependency_locator.dart';
import '../entities/exceptions/call_through.dart';
import '../repositories/call_through.dart';
import '../repositories/memory_storage_repository.dart';
import '../repositories/metrics.dart';
import '../use_case.dart';
import 'get_user.dart';

class GetCallThroughRegionNumberUseCase extends UseCase {
  final _memoryStorageRepository = dependencyLocator<MemoryStorageRepository>();
  final _callThroughRepository = dependencyLocator<CallThroughRepository>();
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  final _getUser = GetUserUseCase();

  Future<String?> call({
    required String destination,
  }) async {
    var regionNumber = _memoryStorageRepository.regionNumber;

    if (regionNumber == null) {
      final user = await _getUser(latest: false);

      if (user == null) {
        throw CallThroughException();
      }

      try {
        regionNumber = await _callThroughRepository.retrieveRegionNumber(
          destination,
          user: user,
        );
      } on CallThroughException catch (e) {
        _metricsRepository.track('call-through-region-number-failed', {
          'error': e.runtimeType.toString(),
        });
        rethrow;
      }

      _memoryStorageRepository.regionNumber = regionNumber;
    }

    return regionNumber;
  }
}

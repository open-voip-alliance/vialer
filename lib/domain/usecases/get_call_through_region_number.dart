import 'dart:async';

import '../../../dependency_locator.dart';
import '../entities/exceptions/call_through.dart';
import '../repositories/call_through.dart';
import '../repositories/memory_storage_repository.dart';
import '../use_case.dart';
import 'get_user.dart';

class GetCallThroughRegionNumberUseCase extends UseCase {
  final _memoryStorageRepository = dependencyLocator<MemoryStorageRepository>();
  final _callThroughRepository = dependencyLocator<CallThroughRepository>();

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

      regionNumber = await _callThroughRepository.retrieveRegionNumber(
        destination,
        user: user,
      );

      _memoryStorageRepository.regionNumber = regionNumber;
    }

    return regionNumber;
  }
}

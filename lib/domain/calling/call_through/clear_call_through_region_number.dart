import '../../../../dependency_locator.dart';
import '../../legacy/memory_storage_repository.dart';
import '../../use_case.dart';

class ClearCallThroughRegionNumberUseCase extends UseCase {
  final _memoryStorageRepository = dependencyLocator<MemoryStorageRepository>();

  void call() => _memoryStorageRepository.clearRegionNumber();
}

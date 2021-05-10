import '../../dependency_locator.dart';
import '../repositories/storage.dart';
import '../use_case.dart';

class IncrementCallThroughCallsCountUseCase extends UseCase {
  final _storageRepository = dependencyLocator<StorageRepository>();

  void call() {
    _storageRepository.callThroughCallsCount ??= 0;

    // Can't use ++ or += 1 since callThroughCallsCount is nullable.
    _storageRepository.callThroughCallsCount =
        _storageRepository.callThroughCallsCount! + 1;
  }
}

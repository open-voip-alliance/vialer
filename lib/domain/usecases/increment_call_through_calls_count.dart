import '../../dependency_locator.dart';
import '../repositories/storage.dart';
import '../use_case.dart';

class IncrementCallThroughCallsCountUseCase extends UseCase<void> {
  final _storageRepository = dependencyLocator<StorageRepository>();

  @override
  void call() {
    _storageRepository.callThroughCallsCount ??= 0;
    _storageRepository.callThroughCallsCount++;
  }
}

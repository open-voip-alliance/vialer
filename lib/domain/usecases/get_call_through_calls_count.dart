import '../../dependency_locator.dart';
import '../repositories/storage.dart';
import '../use_case.dart';

class GetCallThroughCallsCountUseCase extends UseCase<int> {
  final _storageRepository = dependencyLocator<StorageRepository>();

  @override
  int call() => _storageRepository.callThroughCallsCount ?? 0;
}

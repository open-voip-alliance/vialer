import '../../../data/repositories/legacy/storage.dart';
import '../../../dependency_locator.dart';
import '../use_case.dart';

class MarkNowAsLoginTimeUseCase extends UseCase {
  final _storageRepository = dependencyLocator<StorageRepository>();

  void call() => _storageRepository.loginTime = DateTime.now();
}

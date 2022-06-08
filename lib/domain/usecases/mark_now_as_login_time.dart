import '../../dependency_locator.dart';
import '../repositories/storage.dart';
import '../use_case.dart';

class MarkNowAsLoginTimeUseCase extends UseCase {
  final _storageRepository = dependencyLocator<StorageRepository>();

  void call() => _storageRepository.loginTime = DateTime.now();
}

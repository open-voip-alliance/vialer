import '../../dependency_locator.dart';
import '../repositories/storage.dart';
import '../use_case.dart';

class LogoutUseCase extends FutureUseCase<void> {
  final _storageRepository = dependencyLocator<StorageRepository>();

  @override
  Future<void> call() => _storageRepository.clear();
}

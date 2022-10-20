import '../../dependency_locator.dart';
import '../entities/user.dart';
import '../repositories/storage.dart';
import '../use_case.dart';

/// Returns the locally stored user.
class GetStoredUserUseCase extends UseCase {
  final _storageRepository = dependencyLocator<StorageRepository>();

  User? call() => _storageRepository.user;
}

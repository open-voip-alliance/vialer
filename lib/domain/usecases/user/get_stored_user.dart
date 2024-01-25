import '../../../data/models/user/user.dart';
import '../../../data/repositories/legacy/storage.dart';
import '../../../dependency_locator.dart';
import '../use_case.dart';

/// Returns the locally stored user.
class GetStoredUserUseCase extends UseCase {
  final _storageRepository = dependencyLocator<StorageRepository>();

  User? call() => _storageRepository.user;
}

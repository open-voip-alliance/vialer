import '../../dependency_locator.dart';
import '../legacy/storage.dart';
import '../use_case.dart';
import 'user.dart';

/// Returns the locally stored user.
class GetStoredUserUseCase extends UseCase {
  final _storageRepository = dependencyLocator<StorageRepository>();

  User? call() => _storageRepository.user;
}

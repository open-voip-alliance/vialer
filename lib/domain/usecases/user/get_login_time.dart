import '../../../data/repositories/legacy/storage.dart';
import '../../../dependency_locator.dart';
import '../use_case.dart';

class GetLoginTimeUseCase extends UseCase {
  final _storageRepository = dependencyLocator<StorageRepository>();

  /// Only returns `null` for users that have installed the app before we
  /// started tracking login time.
  DateTime? call() => _storageRepository.loginTime;
}

import '../../dependency_locator.dart';
import '../legacy/storage.dart';
import '../use_case.dart';

class GetIsLoggedInSomewhereElseUseCase extends UseCase {
  final _storageRepository = dependencyLocator<StorageRepository>();

  Future<bool> call() async {
    // This is necessary since the change in storage is made in another isolate,
    // meaning that the cache in this isolate is out of date.
    await _storageRepository.reload();

    return _storageRepository.isLoggedInSomewhereElse ?? false;
  }
}

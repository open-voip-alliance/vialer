import '../../../data/repositories/legacy/storage.dart';
import '../../../dependency_locator.dart';
import '../use_case.dart';

class SetIsUsingScreenReader extends UseCase {
  final _storageRepository = dependencyLocator<StorageRepository>();

  Future<bool> call(bool isUsingScreenReader) async =>
      _storageRepository.isUsingScreenReader = isUsingScreenReader;
}

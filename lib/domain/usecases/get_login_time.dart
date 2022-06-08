import '../../dependency_locator.dart';
import '../repositories/storage.dart';
import '../use_case.dart';

class GetLoginTimeUseCase extends UseCase {
  final _storageRepository = dependencyLocator<StorageRepository>();

  DateTime call() => _storageRepository.loginTime!;
}

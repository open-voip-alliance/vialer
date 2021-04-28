import '../../dependency_locator.dart';
import '../repositories/storage.dart';
import '../use_case.dart';

class GetLatestDialedNumberUseCase extends UseCase {
  final _storageRepository = dependencyLocator<StorageRepository>();

  String? call() => _storageRepository.lastDialedNumber;
}

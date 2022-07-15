import '../../dependency_locator.dart';
import '../repositories/storage.dart';
import '../use_case.dart';

class ResetAppRatingSurveyActionCountUseCase extends UseCase {
  final _storageRepository = dependencyLocator<StorageRepository>();

  void call() => _storageRepository.appRatingSurveyActionCount = 0;
}

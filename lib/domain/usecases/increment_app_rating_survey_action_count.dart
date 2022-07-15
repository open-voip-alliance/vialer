import '../../dependency_locator.dart';
import '../repositories/storage.dart';
import '../use_case.dart';

class IncrementAppRatingSurveyActionCountUseCase extends UseCase {
  final _storageRepository = dependencyLocator<StorageRepository>();

  void call() {
    _storageRepository.appRatingSurveyActionCount ??= 0;

    // Can't use ++ or += 1 since appRatingSurveyActionCount is nullable.
    _storageRepository.appRatingSurveyActionCount =
        _storageRepository.appRatingSurveyActionCount! + 1;
  }
}

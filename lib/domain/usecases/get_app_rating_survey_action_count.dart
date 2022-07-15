import '../../dependency_locator.dart';
import '../repositories/storage.dart';
import '../use_case.dart';

class GetAppRatingSurveyActionCountUseCase extends UseCase {
  final _storageRepository = dependencyLocator<StorageRepository>();

  int call() => _storageRepository.appRatingSurveyActionCount ?? 0;
}

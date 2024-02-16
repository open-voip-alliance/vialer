import '../../../../data/repositories/legacy/storage.dart';
import '../../../../dependency_locator.dart';
import '../../use_case.dart';

class GetAppRatingSurveyActionCountUseCase extends UseCase {
  final _storageRepository = dependencyLocator<StorageRepository>();

  int call() => _storageRepository.appRatingSurveyActionCount ?? 0;
}

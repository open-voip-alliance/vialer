import '../../dependency_locator.dart';
import '../repositories/storage.dart';
import '../use_case.dart';

class GetAppRatingSurveyLastShownTimeUseCase extends UseCase {
  final _storageRepository = dependencyLocator<StorageRepository>();

  DateTime? call() => _storageRepository.appRatingSurveyShownTime;
}

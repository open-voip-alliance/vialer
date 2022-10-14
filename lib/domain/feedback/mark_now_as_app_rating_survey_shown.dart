import '../../dependency_locator.dart';
import '../legacy/storage.dart';
import '../use_case.dart';

class MarkNowAsAppRatingSurveyShownUseCase extends UseCase {
  final _storageRepository = dependencyLocator<StorageRepository>();

  void call() => _storageRepository.appRatingSurveyShownTime = DateTime.now();
}

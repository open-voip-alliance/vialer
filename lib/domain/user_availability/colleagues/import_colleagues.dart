import '../../../dependency_locator.dart';
import '../../legacy/storage.dart';
import '../../use_case.dart';
import '../../user/get_logged_in_user.dart';
import 'colleague.dart';
import 'colleagues_repository.dart';

/// Builds up and imports the colleagues into a cache. This should be performed
/// regularly (e.g. when the user opens the app) but should not be refreshed
/// regularly as the data is updated constantly via websockets.
class ImportColleaguesIntoCache extends UseCase {
  late final _colleaguesRepository = dependencyLocator<ColleaguesRepository>();
  late final _storage = dependencyLocator<StorageRepository>();
  late final _getUser = GetLoggedInUserUseCase();

  Future<List<Colleague>> call() async {
    final colleagues = await _colleaguesRepository.getColleagues(_getUser());
    _storage.colleagues = colleagues;
    return colleagues;
  }
}

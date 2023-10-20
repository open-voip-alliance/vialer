import 'package:vialer/domain/user/get_stored_user.dart';

import '../../../dependency_locator.dart';
import '../../use_case.dart';
import '../../user/user.dart';
import 'colleague.dart';
import 'colleagues_repository.dart';

/// Fetches colleagues from remote, this may trigger several API requests
/// to fetch them all.
class FetchColleaguesFromRemote extends UseCase {
  late final _colleaguesRepository = dependencyLocator<ColleaguesRepository>();
  User? get _user => GetStoredUserUseCase()();

  Future<List<Colleague>> call({bool skipCache = false}) async {
    final user = _user;

    if (user == null) return [];

    return _colleaguesRepository.fetchColleagues(user);
  }
}

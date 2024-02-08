import 'package:vialer/domain/usecases/user/get_stored_user.dart';

import '../../../../data/models/relations/colleagues/colleague.dart';
import '../../../../data/models/user/user.dart';
import '../../../../data/repositories/relations/colleagues/colleagues_repository.dart';
import '../../../../dependency_locator.dart';
import '../../use_case.dart';

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

import '../../../../data/models/relations/colleagues/colleague.dart';
import '../../../../data/repositories/relations/colleagues/colleagues_repository.dart';
import '../../../../dependency_locator.dart';
import '../../use_case.dart';

/// This only fetches the most up-to-date list of colleagues that we have
/// mutated based on data from the WebSocket. It does not provide constant
/// updates nor does it fetch any new data.
class GetCachedColleagues extends UseCase {
  late final _colleaguesRepository = dependencyLocator<ColleaguesRepository>();

  Future<List<Colleague>> call() async =>
      _colleaguesRepository.getColleaguesFromCache();
}

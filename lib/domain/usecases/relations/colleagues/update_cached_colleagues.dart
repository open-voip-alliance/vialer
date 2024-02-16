import '../../../../data/models/relations/colleagues/colleague.dart';
import '../../../../data/repositories/relations/colleagues/colleagues_repository.dart';
import '../../../../dependency_locator.dart';
import '../../use_case.dart';

class UpdateCachedColleagues extends UseCase {
  late final _colleaguesRepository = dependencyLocator<ColleaguesRepository>();

  Future<void> call(List<Colleague> colleagues) async =>
      _colleaguesRepository.updateColleaguesCache(colleagues);
}

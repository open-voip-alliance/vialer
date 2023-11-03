import '../../../dependency_locator.dart';
import '../../use_case.dart';
import 'colleague.dart';
import 'colleagues_repository.dart';

class UpdateCachedColleagues extends UseCase {
  late final _colleaguesRepository = dependencyLocator<ColleaguesRepository>();

  Future<void> call(List<Colleague> colleagues) async =>
      _colleaguesRepository.updateColleaguesCache(colleagues);
}

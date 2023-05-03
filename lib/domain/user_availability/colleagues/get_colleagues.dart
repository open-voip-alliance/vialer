import '../../../dependency_locator.dart';
import '../../use_case.dart';
import 'colleague.dart';
import 'colleagues_repository.dart';
import 'receive_colleague_availability.dart';

/// This only fetches the most up-to-date list of colleagues that we have
/// mutated based on data from the WebSocket. It does not provide constant
/// updates nor does it fetch any new data. If any of this is required, make
/// sure to use [ReceiveColleagueAvailability].
///
/// This assumes that the WebSocket has been booted already.
class GetColleagues extends UseCase {
  late final _colleaguesRepository = dependencyLocator<ColleaguesRepository>();

  Future<List<Colleague>> call() async => _colleaguesRepository.colleagues;
}

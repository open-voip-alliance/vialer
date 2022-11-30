import '../../../dependency_locator.dart';
import '../../use_case.dart';
import 'colleagues_repository.dart';

/// Stop receiving updates from the availability WebSocket.
class StopReceivingColleagueAvailability extends UseCase {
  late final _colleagueRepository = dependencyLocator<ColleaguesRepository>();

  Future<void> call() => _colleagueRepository.stopListeningForAvailability();
}

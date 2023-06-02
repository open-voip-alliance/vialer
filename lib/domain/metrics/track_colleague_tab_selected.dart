import '../../../dependency_locator.dart';
import '../use_case.dart';
import 'metrics.dart';

class TrackColleagueTabSelectedUseCase extends UseCase {
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  void call() => _metricsRepository.track('colleague-tab-selected');
}

import '../../../dependency_locator.dart';
import '../use_case.dart';
import 'metrics.dart';

class TrackToggleMuteUseCase extends UseCase {
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  void call() => _metricsRepository.track('toggle-mute');
}

import '../../../../../data/repositories/metrics/metrics.dart';
import '../../../../dependency_locator.dart';
import '../use_case.dart';

class TrackCopyNumberUseCase extends UseCase {
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  void call() => _metricsRepository.track('number-copied');
}

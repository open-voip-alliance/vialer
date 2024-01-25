import '../../../../../data/repositories/metrics/metrics.dart';
import '../../../../dependency_locator.dart';
import '../use_case.dart';

class TrackToggleHoldUseCase extends UseCase {
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  void call() => _metricsRepository.track('call-ongoing-hold-toggled');
}

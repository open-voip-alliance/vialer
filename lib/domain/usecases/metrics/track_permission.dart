import '../../../../../data/repositories/metrics/metrics.dart';
import '../../../../dependency_locator.dart';
import '../use_case.dart';

class TrackPermissionUseCase extends UseCase {
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  void call({
    required String type,
    required bool granted,
  }) =>
      _metricsRepository.track('permission', {
        'type': type,
        'granted': granted,
      });
}

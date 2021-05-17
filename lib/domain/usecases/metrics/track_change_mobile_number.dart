import '../../../dependency_locator.dart';
import '../../repositories/metrics.dart';
import '../../use_case.dart';

class TrackChangeMobileNumberUseCase extends UseCase {
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  Future<void> call() => _metricsRepository.track('change-mobile-number');
}

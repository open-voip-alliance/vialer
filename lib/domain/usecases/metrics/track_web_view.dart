import '../../../../../data/repositories/metrics/metrics.dart';
import '../../../../dependency_locator.dart';
import '../use_case.dart';

class TrackWebViewUseCase extends UseCase {
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  void call({required String page}) => _metricsRepository.track(
        'web-view-opened',
        {'page': page},
      );
}

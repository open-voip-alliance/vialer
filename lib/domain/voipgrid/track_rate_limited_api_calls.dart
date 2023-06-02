import '../../dependency_locator.dart';
import '../metrics/metrics.dart';
import '../use_case.dart';

class TrackRateLimitedApiCalls extends UseCase {
  late final _metrics = dependencyLocator<MetricsRepository>();

  void call(String url) => _metrics.track('api-request-rate-limited', {
        'url': url,
      });
}

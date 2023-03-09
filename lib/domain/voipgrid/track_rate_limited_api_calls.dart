import '../../dependency_locator.dart';
import '../metrics/metrics.dart';
import '../use_case.dart';

class TrackRateLimitedApiCalls extends UseCase {
  late final _metrics = dependencyLocator<MetricsRepository>();

  Future<void> call(String url) =>
      _metrics.track('api-request-was-rate-limited', {
        'url': url,
      });
}

import '../../../../../data/repositories/metrics/metrics.dart';
import '../../../../dependency_locator.dart';
import '../use_case.dart';

class TrackUserInitiatedOutboundCall extends UseCase {
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  void call({
    required String via,
    required bool isVoip,
    required CallType type,
  }) =>
      _metricsRepository.track('call-outbound-by-user-initiated', {
        'via': via,
        'voip': isVoip,
        'type': type.toString(),
      });
}

enum CallType {
  standard,
  pickupGroup,
}

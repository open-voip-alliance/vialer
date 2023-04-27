import '../../../dependency_locator.dart';
import '../use_case.dart';
import 'metrics.dart';

class TrackUserInitiatedOutboundCall extends UseCase {
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  void call({
    required String via,
    required bool isVoip,
    required CallType type,
  }) =>
      _metricsRepository.track('call-initiated-by-user', {
        'via': via,
        'voip': isVoip,
        'type': type.toString(),
      });
}

enum CallType {
  standard,
  pickupGroup,
}

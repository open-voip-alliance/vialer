import '../../../dependency_locator.dart';
import '../calling/call_failure_reason.dart';
import '../use_case.dart';
import 'metrics.dart';

class TrackOutboundCallFailedUseCase extends UseCase {
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  void call({
    required CallFailureReason reason,
    bool isVoip = true,
    String? message,
  }) =>
      _metricsRepository.track('outbound-call-failed', {
        'reason': reason.name,
        'voip': isVoip,
        'message': message,
      });
}

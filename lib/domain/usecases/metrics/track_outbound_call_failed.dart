import 'dart:async';

import '../../../dependency_locator.dart';
import '../../entities/call_failure_reason.dart';
import '../../repositories/metrics.dart';
import '../../use_case.dart';

class TrackOutboundCallFailedUseCase extends UseCase {
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  Future<void> call({
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

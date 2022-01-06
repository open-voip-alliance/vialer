import 'dart:async';

import '../../../dependency_locator.dart';
import '../../repositories/metrics.dart';
import '../../use_case.dart';

class TrackOutboundCallFailedUseCase extends UseCase {
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  Future<void> call({
    required Reason reason,
    String? message,
  }) =>
      _metricsRepository.track('outbound-call-failed', {
        'reason': reason.name,
        'message': message,
      });
}

enum Reason {
  invalidCallState,
  noMicrophonePermission,
  noConnectivity,
  unknown,
}

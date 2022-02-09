import 'dart:async';

import '../../../dependency_locator.dart';
import '../../repositories/metrics.dart';
import '../../use_case.dart';

class TrackUserInitiatedOutboundCall extends UseCase {
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  Future<void> call({
    required String via,
    required bool isVoip,
  }) =>
      _metricsRepository.track('call-initiated-by-user', {
        'via': via,
        'voip': isVoip,
      });
}

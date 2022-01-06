import 'dart:async';

import '../../../dependency_locator.dart';
import '../../repositories/metrics.dart';
import '../../use_case.dart';

class TrackUserInitiatedOutboundCall extends UseCase {
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  Future<void> call({
    required String via,
  }) =>
      _metricsRepository.track('user-intiated-outbound-call', {
        'via': via,
      });
}

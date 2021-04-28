import 'dart:async';

import '../../../dependency_locator.dart';
import '../../repositories/metrics.dart';
import '../../use_case.dart';

class TrackCallUseCase extends UseCase {
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  Future<void> call({
    required String via,
    required bool voip,
  }) =>
      _metricsRepository.track(
        'call',
        {
          'via': via,
          'voip': voip,
        },
      );
}

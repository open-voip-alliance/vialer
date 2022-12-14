import 'dart:async';

import '../../../dependency_locator.dart';
import '../use_case.dart';
import 'metrics.dart';

class TrackCopyNumberUseCase extends UseCase {
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  Future<void> call() => _metricsRepository.track('copy-number');
}

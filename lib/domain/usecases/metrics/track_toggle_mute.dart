import 'dart:async';

import '../../../dependency_locator.dart';
import '../../repositories/metrics.dart';
import '../../use_case.dart';

class TrackToggleMuteUseCase extends UseCase {
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  Future<void> call() => _metricsRepository.track('toggle-mute');
}

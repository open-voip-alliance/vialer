import 'dart:async';

import '../../../dependency_locator.dart';
import '../use_case.dart';
import 'metrics.dart';

class TrackPermissionUseCase extends UseCase {
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  Future<void> call({
    required String type,
    required bool granted,
  }) =>
      _metricsRepository.track('permission', {
        'type': type,
        'granted': granted,
      });
}

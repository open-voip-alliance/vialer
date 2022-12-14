import 'dart:async';

import '../../../dependency_locator.dart';
import '../use_case.dart';
import 'metrics.dart';

class TrackWebViewUseCase extends UseCase {
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  Future<void> call({required String page}) => _metricsRepository.track(
        'web-view',
        {'page': page},
      );
}

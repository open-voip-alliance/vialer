import 'dart:async';

import '../../../dependency_locator.dart';
import '../../repositories/metrics.dart';
import '../../use_case.dart';

class TrackLoginUseCase extends UseCase {
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  Future<void> call({required bool usedTwoFactor}) =>
      _metricsRepository.track('login', {'two-factor': usedTwoFactor});
}

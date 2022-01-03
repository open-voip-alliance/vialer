import 'dart:async';

import '../../../dependency_locator.dart';
import '../../repositories/metrics.dart';
import '../../use_case.dart';

class TrackLoginUseCase extends UseCase {
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  Future<void> call({
    required bool usedTwoFactor,
    required bool isLoginFromLegacyApp,
  }) =>
      _metricsRepository.track('login', {
        'two-factor': usedTwoFactor,
        'is-login-from-legacy-app': isLoginFromLegacyApp,
      });
}

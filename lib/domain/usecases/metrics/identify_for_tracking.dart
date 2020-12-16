import 'dart:async';

import '../../../dependency_locator.dart';
import '../../repositories/auth.dart';
import '../../repositories/metrics.dart';
import '../../use_case.dart';

class IdentifyForTrackingUseCase extends FutureUseCase<void> {
  final _metricsRepository = dependencyLocator<MetricsRepository>();
  final _authRepository = dependencyLocator<AuthRepository>();

  @override
  Future<void> call() async {
    assert(_authRepository.currentUser != null);
    await _metricsRepository.identify(_authRepository.currentUser.uuid);
  }
}

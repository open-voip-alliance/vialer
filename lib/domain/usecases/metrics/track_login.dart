import 'dart:async';

import '../../../../domain/entities/permission.dart';
import '../../../dependency_locator.dart';
import '../../entities/permission.dart';
import '../../entities/permission_status.dart';
import '../../repositories/metrics.dart';
import '../../use_case.dart';
import '../get_permission_status.dart';

class TrackLoginUseCase extends UseCase {
  final _metricsRepository = dependencyLocator<MetricsRepository>();
  final _getPermissionStatus = GetPermissionStatusUseCase();

  Future<void> call({
    required bool usedTwoFactor,
    required bool isLoginFromLegacyApp,
  }) async =>
      _metricsRepository.track('login', {
        'two-factor': usedTwoFactor,
        'is-login-from-legacy-app': isLoginFromLegacyApp,
        'is_ignoring_battery_optimizations': await _getPermissionStatus(
          permission: Permission.ignoreBatteryOptimizations,
        ).then(
          (status) => status == PermissionStatus.granted,
        ),
      });
}

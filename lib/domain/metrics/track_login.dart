import 'dart:async';

import '../../../dependency_locator.dart';
import '../use_case.dart';
import '../user/get_permission_status.dart';
import '../user/permissions/permission.dart';
import '../user/permissions/permission_status.dart';
import 'metrics.dart';

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

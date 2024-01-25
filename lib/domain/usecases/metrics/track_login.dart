import 'dart:async';

import '../../../../../data/repositories/metrics/metrics.dart';
import '../../../../dependency_locator.dart';
import '../../../data/models/user/permissions/permission.dart';
import '../../../data/models/user/permissions/permission_status.dart';
import '../use_case.dart';
import '../user/get_permission_status.dart';

class TrackLoginUseCase extends UseCase {
  final _metricsRepository = dependencyLocator<MetricsRepository>();
  final _getPermissionStatus = GetPermissionStatusUseCase();

  Future<void> call({
    required bool usedTwoFactor,
    required bool isLoginFromLegacyApp,
  }) async =>
      _metricsRepository.track('user-logged-in', {
        'two-factor': usedTwoFactor,
        'is-login-from-legacy-app': isLoginFromLegacyApp,
        'is_ignoring_battery_optimizations': await _getPermissionStatus(
          permission: Permission.ignoreBatteryOptimizations,
        ).then(
          (status) => status == PermissionStatus.granted,
        ),
      });
}

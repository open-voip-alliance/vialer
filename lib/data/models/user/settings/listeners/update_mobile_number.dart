import 'dart:async';

import '../../../../../data/repositories/metrics/metrics.dart';
import '../../../../../dependency_locator.dart';
import '../../../../../presentation/util/loggable.dart';
import '../../../../repositories/authentication/authentication_repository.dart';
import '../../user.dart';
import '../call_setting.dart';
import 'setting_change_listener.dart';

class UpdateMobileNumberListener extends SettingChangeListener<String>
    with Loggable {
  final _authRepository = dependencyLocator<AuthRepository>();
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  @override
  final key = CallSetting.mobileNumber;

  @override
  FutureOr<SettingChangeListenResult> applySettingsSideEffects(
    User user,
    String value,
  ) =>
      changeRemoteValue(
        () async {
          final success = await _authRepository.changeMobileNumber(value);
          if (success) {
            _metricsRepository.track('mobile-number-changed');
          }
          logger.info('Updating of mobile number succeeded: $success');
          return success;
        },
      );
}

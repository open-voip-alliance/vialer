import 'dart:async';

import '../../../../app/util/loggable.dart';
import '../../../../dependency_locator.dart';
import '../../../authentication/authentication_repository.dart';
import '../../../metrics/metrics.dart';
import '../../../user/user.dart';
import '../call_setting.dart';
import 'setting_change_listener.dart';

class UpdateMobileNumberListener extends SettingChangeListener<String>
    with Loggable {
  final _authRepository = dependencyLocator<AuthRepository>();
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  @override
  final key = CallSetting.mobileNumber;

  @override
  FutureOr<SettingChangeListenResult> preStore(User user, String value) =>
      changeRemoteValue(() async {
        final success = await _authRepository.changeMobileNumber(value);
        if (success) {
          _metricsRepository.track('change-mobile-number');
        }
        logger.info('Updating of mobile number succeeded: $success');
        return success;
      });
}

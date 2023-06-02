import 'dart:async';

import '../../../../app/util/loggable.dart';
import '../../../../dependency_locator.dart';
import '../../../calling/outgoing_number/outgoing_numbers.dart';
import '../../../metrics/metrics.dart';
import '../../../user/user.dart';
import '../call_setting.dart';
import 'setting_change_listener.dart';

class UpdateOutgoingNumberListener extends SettingChangeListener<OutgoingNumber>
    with Loggable {
  final _outgoingNumbersRepository =
      dependencyLocator<OutgoingNumbersRepository>();
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  @override
  final key = CallSetting.outgoingNumber;

  @override
  FutureOr<SettingChangeListenResult> preStore(
    User user,
    OutgoingNumber value,
  ) =>
      changeRemoteValue(() async {
        if (value is SuppressedOutgoingNumber) {
          logger.info("Attempting to suppress the user's outgoing number");

          _metricsRepository.track('outgoing-number-suppressed');

          return _outgoingNumbersRepository.suppressOutgoingNumber(user: user);
        }

        logger.info("Changing the user's outgoing number");

        _metricsRepository.track('outgoing-number-changed');

        return _outgoingNumbersRepository.changeOutgoingNumber(
          user: user,
          number: (value as UnsuppressedOutgoingNumber).value,
        );
      });
}

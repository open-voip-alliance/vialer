import 'dart:async';
import 'dart:math';

import 'package:dartx/dartx.dart';

import '../../../../app/util/loggable.dart';
import '../../../../dependency_locator.dart';
import '../../../calling/outgoing_number/outgoing_numbers.dart';
import '../../../legacy/storage.dart';
import '../../../metrics/metrics.dart';
import '../../../user/user.dart';
import '../call_setting.dart';
import 'setting_change_listener.dart';

class UpdateOutgoingNumberListener extends SettingChangeListener<OutgoingNumber>
    with Loggable {
  static const _maxRecents = 5;

  final _outgoingNumbersRepository =
      dependencyLocator<OutgoingNumbersRepository>();
  final _metricsRepository = dependencyLocator<MetricsRepository>();
  final _storageRepository = dependencyLocator<StorageRepository>();

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

        final number = (value as UnsuppressedOutgoingNumber).value;

        // Store the last recent and unique outgoing numbers for easy access.
        final recentOutgoingNumbers = _storageRepository.recentOutgoingNumbers
            .prependElement(value)
            .distinct();
        _storageRepository.recentOutgoingNumbers = recentOutgoingNumbers.slice(
            0, min(recentOutgoingNumbers.length - 1, _maxRecents - 1));

        return _outgoingNumbersRepository.changeOutgoingNumber(
          user: user,
          number: number,
        );
      });
}

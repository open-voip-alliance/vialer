import 'dart:async';

import '../../../../app/util/loggable.dart';
import '../../../../dependency_locator.dart';
import '../../../calling/voip/destination.dart';
import '../../../calling/voip/destination_repository.dart';
import '../../../metrics/metrics.dart';
import '../../../user/user.dart';
import '../call_setting.dart';
import 'setting_change_listener.dart';

class UpdateDestinationListener extends SettingChangeListener<Destination>
    with Loggable {
  final _destinationRepository = dependencyLocator<DestinationRepository>();
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  @override
  final key = CallSetting.destination;

  @override
  FutureOr<SettingChangeListenResult> preStore(
    User user,
    Destination newDestination,
  ) async {
    final currentDestination =
        await _destinationRepository.getActiveDestination();

    var log = true;

    if (currentDestination != newDestination) {
      newDestination.when(
        notAvailable: () => logger.info('Set $key to $newDestination'),
        phoneNumber: (id, _, __) => logger.info('Set $key to $id'),
        phoneAccount: (id, _, __, ___) => logger.info('Set $key to $id'),
      );

      log = false;
    }

    return changeRemoteValue(log: log, () async {
      final success = await _destinationRepository.setDestination(
        destination: newDestination,
      );

      if (success) {
        _metricsRepository.track('destination-changed', {
          'has-app-account': user.appAccountUrl != null,
          'to-fixed-destination': newDestination is PhoneNumber,
          'to-phone-account': newDestination is PhoneAccount,
        });
      }

      return success;
    });
  }
}

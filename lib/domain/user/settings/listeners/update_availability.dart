import 'dart:async';

import '../../../../app/util/loggable.dart';
import '../../../../dependency_locator.dart';
import '../../../calling/voip/availability_repository.dart';
import '../../../calling/voip/destination.dart';
import '../../../calling/voip/destinations.dart';
import '../../../metrics/metrics.dart';
import '../../../user/user.dart';
import '../call_setting.dart';
import 'setting_change_listener.dart';

class UpdateDestinationListener extends SettingChangeListener<Destinations>
    with Loggable {
  final _availabilityRepository = dependencyLocator<AvailabilityRepository>();
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  @override
  final key = CallSetting.destinations;

  @override
  FutureOr<SettingChangeListenResult> preSave(
    User user,
    Destinations destinations,
  ) async {
    final latestDestinations =
        await _availabilityRepository.getLatestDestinations();

    final oldActiveDestination = latestDestinations?.activeDestination;
    final newActiveDestination = destinations.activeDestination;

    var log = true;

    if (oldActiveDestination != newActiveDestination) {
      newActiveDestination.when(
        notAvailable: () => logger.info('Set $key to $newActiveDestination'),
        phoneNumber: (id, _, __) => logger.info('Set $key to $id'),
        phoneAccount: (id, _, __, ___) => logger.info('Set $key to $id'),
      );

      log = false;
    }

    final destination = destinations.activeDestination;

    return changeRemoteValue(log: log, () async {
      final success = await _availabilityRepository.setDestination(
        selectedDestinationId: destinations.selectedDestinationId,
        destination: destination,
      );

      if (success) {
        _metricsRepository.track('destination-changed', {
          'has-app-account': user.appAccountUrl != null,
          'to-fixed-destination': destination is PhoneNumber,
          'to-phone-account': destination is PhoneAccount,
        });
      }

      return success;
    });
  }
}

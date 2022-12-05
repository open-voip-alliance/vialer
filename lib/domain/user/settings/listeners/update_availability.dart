import 'dart:async';

import '../../../../app/util/loggable.dart';
import '../../../../dependency_locator.dart';
import '../../../calling/voip/availability_repository.dart';
import '../../../metrics/metrics.dart';
import '../../../user/user.dart';
import '../call_setting.dart';
import 'setting_change_listener.dart';

class UpdateAvailabilityListener extends SettingChangeListener<Destinations>
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

    final oldActiveDestination = latestDestinations?.activeDestination ?? null;
    final newActiveDestination = destinations.activeDestination;

    var log = true;

    if (oldActiveDestination != newActiveDestination) {
      // if ((newActiveDestination is PhoneAccount) |
      //     (newActiveDestination is PhoneNumber)) {
      //   logger.info('Set $key to ${newActiveDestination.id}');
      // } else {
      //   // NotAvailable
      //   logger.info('Set $key to $newActiveDestination');
      // }

      // if (newActiveDestination is PhoneAccount) {
      //   logger.info('Set $key to ${newActiveDestination.id}');
      // } else if (newActiveDestination is PhoneNumber) {
      //   logger.info('Set $key to ${newActiveDestination.id}');
      // } else {
      //   // NotAvailable
      //   logger.info('Set $key to $newActiveDestination');
      // }

      logger.info('Set $key to $newActiveDestination');

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

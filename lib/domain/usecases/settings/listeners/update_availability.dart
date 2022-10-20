import 'dart:async';

import '../../../../app/util/loggable.dart';
import '../../../../dependency_locator.dart';
import '../../../entities/availability.dart';
import '../../../entities/settings/call_setting.dart';
import '../../../entities/user.dart';
import '../../../repositories/destination.dart';
import '../../../repositories/metrics.dart';
import 'setting_change_listener.dart';

class UpdateAvailabilityListener extends SettingChangeListener<Availability>
    with Loggable {
  final _destinationRepository = dependencyLocator<DestinationRepository>();
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  @override
  final key = CallSetting.availability;

  @override
  FutureOr<SettingChangeListenResult> beforeStore(
    User user,
    Availability availability,
  ) async {
    final latestAvailability =
        await _destinationRepository.getLatestAvailability();
    final oldDestinationInfo =
        latestAvailability?.selectedDestinationInfo ?? null;
    final newDestinationInfo = availability.selectedDestinationInfo ?? null;

    var log = true;

    if (oldDestinationInfo != newDestinationInfo) {
      // Only log the destination, since the whole availability object
      // contains too much privacy sensitive information.
      logger.info('Set $key to ${availability.selectedDestinationInfo}');
      log = false;
    }

    final destination = availability.selectedDestinationInfo!;

    return changeRemoteValue(log: log, () async {
      final success = await _destinationRepository.setAvailability(
        selectedDestinationId: destination.id,
        phoneAccountId: destination.phoneAccountId,
        fixedDestinationId: destination.fixedDestinationId,
      );

      _metricsRepository.track('destination-changed', {
        'has-app-account': user.appAccountUrl != null,
        'to-fixed-destination': destination.fixedDestinationId != null,
        'to-phone-account': destination.phoneAccountId != null,
      });

      return success;
    });
  }
}

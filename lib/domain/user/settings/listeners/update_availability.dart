import 'dart:async';

import '../../../../app/util/loggable.dart';
import '../../../../dependency_locator.dart';
import '../../../calling/voip/destination.dart';
import '../../../calling/voip/destination_repository.dart';
import '../../../metrics/metrics.dart';
import '../../../user/user.dart';
import '../../../user_availability/colleagues/colleagues_repository.dart';
import '../call_setting.dart';
import 'setting_change_listener.dart';

class UpdateDestinationListener extends SettingChangeListener<Destination>
    with Loggable {
  final _destinationRepository = dependencyLocator<DestinationRepository>();
  final _metricsRepository = dependencyLocator<MetricsRepository>();
  final _colleagueRepository = dependencyLocator<ColleaguesRepository>();

  /// When we are connected to the Colleague WebSocket we will automatically
  /// get availability updates pushed to us, so to avoid refreshing the user
  /// multiple times we will not do it while connected to the ws.
  bool get _shouldSyncUser => !_colleagueRepository.isWebSocketConnected;

  @override
  final key = CallSetting.destination;

  @override
  FutureOr<SettingChangeListenResult> preStore(
    User user,
    Destination value,
  ) async {
    final currentDestination =
        await _destinationRepository.getActiveDestination();

    var log = true;

    if (currentDestination != value) {
      value.when(
        unknown: () => logger.info('Set $key to $value'),
        notAvailable: () => logger.info('Set $key to $value'),
        phoneNumber: (id, _, __) => logger.info('Set $key to $id'),
        phoneAccount: (id, _, __, ___) => logger.info('Set $key to $id'),
      );

      log = false;
    }

    final success = await _destinationRepository.setDestination(
      destination: value,
    );

    if (success) {
      unawaited(
        _metricsRepository.track('destination-changed', <String, dynamic>{
          'has-app-account': user.appAccountUrl != null,
          'to-fixed-destination': value is PhoneNumber,
          'to-phone-account': value is PhoneAccount,
        }),
      );
    }

    return SettingChangeListenResult(log: log, sync: _shouldSyncUser);
  }
}

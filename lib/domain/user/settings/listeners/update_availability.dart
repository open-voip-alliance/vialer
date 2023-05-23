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
    final success = await _destinationRepository.setDestination(
      destination: value,
    );

    if (success) {
      _track(user, value);
    }

    return SettingChangeListenResult(sync: _shouldSyncUser);
  }

  Future<void> _track(User user, Destination destination) async {
    final destinationId =
        destination is PhoneAccount ? destination.id.toString() : null;

    final isFixedDestination = destination is PhoneNumber;
    final isMobile =
        destinationId != null && destinationId == user.appAccountId;
    final isWebphone =
        destinationId != null && destinationId == user.webphoneAccountId;

    return _metricsRepository.track(
      'destination-changed',
      {
        'has-app-account': user.appAccountUrl != null,
        'to-phone-account': destination is PhoneAccount,
        'to-fixed-destination': isFixedDestination,
        'to-mobile': isMobile,
        'to-webphone': isWebphone,
        'to-desk-phone': !isFixedDestination && !isMobile && !isWebphone,
      },
    );
  }
}

import 'dart:async';

import '../../../../app/util/loggable.dart';
import '../../../../dependency_locator.dart';
import '../../../calling/voip/destination.dart';
import '../../../calling/voip/destination_repository.dart';
import '../../../metrics/metrics.dart';
import '../../../relations/websocket/relations_web_socket.dart';
import '../../../user/user.dart';
import '../call_setting.dart';
import 'setting_change_listener.dart';

class UpdateDestinationListener extends SettingChangeListener<int>
    with Loggable {
  final _destinationRepository = dependencyLocator<DestinationRepository>();
  final _metricsRepository = dependencyLocator<MetricsRepository>();
  final _relationsWebSocket = dependencyLocator<RelationsWebSocket>();

  /// When we are connected to the Colleague WebSocket we will automatically
  /// get availability updates pushed to us, so to avoid refreshing the user
  /// multiple times we will not do it while connected to the ws.
  bool get _shouldSyncUser => !_relationsWebSocket.isWebSocketConnected;

  @override
  final key = CallSetting.destination;

  @override
  FutureOr<SettingChangeListenResult> applySettingsSideEffects(
    User user,
    int value,
  ) async {
    final success = await _destinationRepository.setDestination(
      destination: value.asDestination(),
    );

    if (success) {
      _track(user, value.asDestination());
    }

    return SettingChangeListenResult(sync: _shouldSyncUser);
  }

  Future<void> _track(User user, Destination destination) async {
    final destinationId =
        destination is PhoneAccount ? destination.id.toString() : null;

    final isOffline = destination is NotAvailable;
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
        'to-desk-phone':
            !isOffline && !isFixedDestination && !isMobile && !isWebphone,
        'to-offline': isOffline,
      },
    );
  }
}

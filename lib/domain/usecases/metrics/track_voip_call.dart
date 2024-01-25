import 'package:connection_network_type/connection_network_type.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter_phone_lib/flutter_phone_lib.dart';

import '../../../../../data/repositories/metrics/metrics.dart';
import '../../../../dependency_locator.dart';
import '../../../data/repositories/user/connectivity/connectivity.dart';
import '../use_case.dart';

class TrackVoipCallUseCase extends UseCase {
  final _metricsRepository = dependencyLocator<MetricsRepository>();
  final _connectivityRepository = dependencyLocator<ConnectivityRepository>();

  Future<void> call({
    required CallDirection direction,
    required Set<AudioRoute> usedRoutes,
    required Set<String> usedBluetoothDevices,
    required double mos,
    String? reason,
  }) async {
    final connectivityType = await _connectivityRepository.currentType;
    final networkStatus = await ConnectionNetworkType().currentNetworkStatus();

    _metricsRepository.track('voip-call-ended', {
      'direction': direction.toTrackString(),
      'bluetooth-used': usedRoutes.contains(AudioRoute.bluetooth),
      'phone-used': usedRoutes.contains(AudioRoute.phone),
      'speaker-used': usedRoutes.contains(AudioRoute.speaker),
      'connection': connectivityType.toString(),
      'mobile-data-connectivity-type': networkStatus.toTrackString(),
      'bluetooth-device-last': usedBluetoothDevices.lastOrNull,
      'bluetooth-device-count': usedBluetoothDevices.length,
      'bluetooth-device-list': usedBluetoothDevices.join(','),
      'reason': reason,
      'mos': mos,
    });
  }
}

extension on NetworkStatus {
  // Should be null if it's not a mobile network.
  String? toTrackString() => switch (this) {
        NetworkStatus.mobile2G => '2G',
        NetworkStatus.mobile3G => '3G',
        NetworkStatus.mobile4G => '4G',
        NetworkStatus.mobile5G => '5G',
        NetworkStatus.otherMobile => 'other',
        _ => null,
      };
}

extension CallDirectionForMetrics on CallDirection {
  String toTrackString() =>
      this == CallDirection.inbound ? 'inbound' : 'outbound';
}

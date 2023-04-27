import 'package:dartx/dartx.dart';
import 'package:flutter_phone_lib/flutter_phone_lib.dart';

import '../../../dependency_locator.dart';
import '../use_case.dart';
import '../user/connectivity/connectivity.dart';
import 'metrics.dart';

class TrackVoipCallUseCase extends UseCase {
  final _metricsRepository = dependencyLocator<MetricsRepository>();
  final _connectivityRepository = dependencyLocator<ConnectivityRepository>();

  void call({
    required CallDirection direction,
    required Set<AudioRoute> usedRoutes,
    required Set<String> usedBluetoothDevices,
    required double mos,
    String? reason,
  }) {
    final connectivityType = _connectivityRepository.currentType;

    _metricsRepository.track('voip-call', <String, dynamic>{
      'direction': direction.toTrackString(),
      'bluetooth-used': usedRoutes.contains(AudioRoute.bluetooth),
      'phone-used': usedRoutes.contains(AudioRoute.phone),
      'speaker-used': usedRoutes.contains(AudioRoute.speaker),
      'connection': connectivityType.toString(),
      'bluetooth-device-last': usedBluetoothDevices.lastOrNull,
      'bluetooth-device-count': usedBluetoothDevices.length,
      'bluetooth-device-list': usedBluetoothDevices.join(','),
      'reason': reason,
      'mos': mos,
    });
  }
}

extension CallDirectionForMetrics on CallDirection {
  String toTrackString() =>
      this == CallDirection.inbound ? 'inbound' : 'outbound';
}

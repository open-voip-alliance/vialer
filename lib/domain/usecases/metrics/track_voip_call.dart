import 'dart:async';

import 'package:flutter_phone_lib/flutter_phone_lib.dart';

import '../../../dependency_locator.dart';
import '../../repositories/connectivity.dart';
import '../../repositories/metrics.dart';
import '../../use_case.dart';

class TrackVoipCallUseCase extends UseCase {
  final _metricsRepository = dependencyLocator<MetricsRepository>();
  final _connectivityRepository = dependencyLocator<ConnectivityRepository>();

  Future<void> call({
    required CallDirection direction,
    required Set<AudioRoute> usedRoutes,
    String? reason,
  }) async {
    final connectivityType = await _connectivityRepository.currentType;

    _metricsRepository.track('voip-call', {
      'direction': direction.toTrackString(),
      'bluetooth-used': usedRoutes.contains(AudioRoute.bluetooth),
      'phone-used': usedRoutes.contains(AudioRoute.phone),
      'speaker-used': usedRoutes.contains(AudioRoute.speaker),
      'connection': connectivityType.toString(),
      'reason': reason,
    });
  }
}

extension CallDirectionForMetrics on CallDirection {
  String toTrackString() =>
      this == CallDirection.inbound ? 'inbound' : 'outbound';
}

import 'dart:async';

import 'package:flutter_phone_lib/flutter_phone_lib.dart';

import '../../../dependency_locator.dart';
import '../../repositories/connectivity.dart';
import '../../repositories/metrics.dart';
import '../../use_case.dart';

class TrackCallUseCase extends UseCase {
  final _metricsRepository = dependencyLocator<MetricsRepository>();
  final _connectivityRepository = dependencyLocator<ConnectivityRepository>();

  Future<void> call({
    required String via,
    required bool voip,
    required CallDirection direction,
    required Set<AudioRoute> usedRoutes,
  }) async {
    final connectivityType = await _connectivityRepository.currentType;

    _metricsRepository.track('call', {
      'via': via,
      'voip': voip,
      'direction': direction == CallDirection.inbound ? 'inbound' : 'outbound',
      'bluetooth-used': usedRoutes.contains(AudioRoute.bluetooth),
      'phone-used': usedRoutes.contains(AudioRoute.phone),
      'speaker-used': usedRoutes.contains(AudioRoute.speaker),
      'connection': connectivityType.toString(),
    });
  }
}

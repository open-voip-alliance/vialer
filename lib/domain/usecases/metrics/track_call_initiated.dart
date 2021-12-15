import 'dart:async';

import 'package:flutter_phone_lib/flutter_phone_lib.dart';

import '../../../dependency_locator.dart';
import '../../repositories/connectivity.dart';
import '../../repositories/metrics.dart';
import '../../use_case.dart';
import 'track_voip_call.dart';

class TrackVoipCallStartedUseCase extends UseCase {
  final _metricsRepository = dependencyLocator<MetricsRepository>();
  final _connectivityRepository = dependencyLocator<ConnectivityRepository>();

  Future<void> call({
    required String via,
    required CallDirection direction,
  }) async {
    final connectivityType = await _connectivityRepository.currentType;

    _metricsRepository.track('voip-call-started', {
      'via': via,
      'direction': direction.toTrackString(),
      'connection': connectivityType.toString(),
    });
  }
}

import 'dart:async';

import 'package:flutter_phone_lib/flutter_phone_lib.dart';

import '../../../../../data/repositories/metrics/metrics.dart';
import '../../../../dependency_locator.dart';
import '../../../data/repositories/user/connectivity/connectivity.dart';
import '../use_case.dart';
import 'track_voip_call.dart';

class TrackCallThroughCallUseCase extends UseCase {
  final _metricsRepository = dependencyLocator<MetricsRepository>();
  final _connectivityRepository = dependencyLocator<ConnectivityRepository>();

  Future<void> call({
    required String via,
    required CallDirection direction,
  }) async {
    final connectivityType = await _connectivityRepository.currentType;

    _metricsRepository.track('call-through-call-started', {
      'via': via,
      'voip': false,
      'direction': direction.toTrackString(),
      'connection': connectivityType.toString(),
    });
  }
}

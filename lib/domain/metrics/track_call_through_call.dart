import 'dart:async';

import 'package:flutter_phone_lib/flutter_phone_lib.dart';

import '../../../dependency_locator.dart';
import '../use_case.dart';
import '../user/connectivity/connectivity.dart';
import 'metrics.dart';
import 'track_voip_call.dart';

class TrackCallThroughCallUseCase extends UseCase {
  final _metricsRepository = dependencyLocator<MetricsRepository>();
  final _connectivityRepository = dependencyLocator<ConnectivityRepository>();

  Future<void> call({
    required String via,
    required CallDirection direction,
  }) async {
    final connectivityType = await _connectivityRepository.currentType;

    unawaited(
      _metricsRepository.track('call-through-call', <String, dynamic>{
        'via': via,
        'voip': false,
        'direction': direction.toTrackString(),
        'connection': connectivityType.toString(),
      }),
    );
  }
}

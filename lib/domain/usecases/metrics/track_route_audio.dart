import 'dart:async';

import 'package:flutter_phone_lib/audio/audio_route.dart';
import 'package:meta/meta.dart';

import '../../../dependency_locator.dart';
import '../../repositories/metrics.dart';
import '../../use_case.dart';

class TrackRouteAudioUseCase extends FutureUseCase<void> {
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  @override
  Future<void> call({@required AudioRoute route}) {
    if (route == AudioRoute.speaker) {
      return _metricsRepository.track('route-audio-speaker');
    } else if (route == AudioRoute.bluetooth) {
      return _metricsRepository.track('route-audio-bluetooth');
    }

    return _metricsRepository.track('route-audio-phone');
  }
}

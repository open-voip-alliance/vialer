import 'package:flutter_phone_lib/flutter_phone_lib.dart';

import '../../../../../data/repositories/metrics/metrics.dart';
import '../../../../dependency_locator.dart';
import '../use_case.dart';

class TrackRouteAudioUseCase extends UseCase {
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  void call({required AudioRoute route, String? bluetoothDevice}) {
    if (route == AudioRoute.speaker) {
      _metricsRepository.track('route-audio-speaker');
    } else if (route == AudioRoute.bluetooth) {
      final properties =
          bluetoothDevice != null ? {'device': bluetoothDevice} : null;

      _metricsRepository.track('route-audio-bluetooth', properties);
    }

    _metricsRepository.track('route-audio-phone');
  }
}

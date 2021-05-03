import 'package:flutter_phone_lib/audio/audio_route.dart';
import 'package:flutter_phone_lib/call/call.dart';
import 'package:flutter_phone_lib/call/call_direction.dart';
import 'package:meta/meta.dart';

import '../../../../dependency_locator.dart';
import '../../../repositories/connectivity.dart';
import '../../../repositories/metrics.dart';
import '../../../use_case.dart';

class RateVoipCallUseCase extends FutureUseCase<void> {
  final _metricsRepository = dependencyLocator<MetricsRepository>();
  final _connectivityRepository = dependencyLocator<ConnectivityRepository>();

  @override
  Future<void> call({
    @required int rating,
    @required Call call,
    @required Set<AudioRoute> usedRoutes,
  }) async {
    final connectivityType = await _connectivityRepository.currentType;

    _metricsRepository.track('call-rating', {
      'rating': rating,
      'mos': call.mos,
      'duration': call.duration,
      'direction':
          call.direction == CallDirection.inbound ? 'inbound' : 'outbound',
      'bluetooth-used': usedRoutes.contains(AudioRoute.bluetooth),
      'phone-used': usedRoutes.contains(AudioRoute.phone),
      'speaker-used': usedRoutes.contains(AudioRoute.speaker),
      'audio-routes': _createAudioRouteString(usedRoutes),
      'connection': connectivityType.toString(),
    });
  }

  /// Create a string such as phone|bluetooth that will include
  /// the combination of routes used. This is to provide
  /// alternative ways to view the events in a dashboard.
  String _createAudioRouteString(Set<AudioRoute> routes) => [
        if (routes.contains(AudioRoute.phone)) 'phone',
        if (routes.contains(AudioRoute.speaker)) 'speaker',
        if (routes.contains(AudioRoute.bluetooth)) 'bluetooth',
      ].join('|');
}

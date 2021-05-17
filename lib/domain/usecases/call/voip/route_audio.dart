import 'package:flutter_phone_lib/audio/audio_route.dart';

import '../../../../dependency_locator.dart';
import '../../../repositories/voip.dart';
import '../../../use_case.dart';
import '../../metrics/track_route_audio.dart';

class RouteAudioUseCase extends UseCase {
  final _voipRepository = dependencyLocator<VoipRepository>();
  final _trackRouteAudio = TrackRouteAudioUseCase();

  Future<void> call({required AudioRoute route}) async {
    _trackRouteAudio(route: route);
    await _voipRepository.routeAudio(route);
  }
}

import 'dart:async';

import '../../../../dependency_locator.dart';
import '../../metrics/track_toggle_mute.dart';
import '../../use_case.dart';
import 'voip.dart';

class ToggleMuteVoipCallUseCase extends UseCase {
  final _voipRepository = dependencyLocator<VoipRepository>();
  final _trackToggleMute = TrackToggleMuteUseCase();

  Future<void> call() async {
    _trackToggleMute();
    await _voipRepository.toggleMute();
  }
}

import '../../../../dependency_locator.dart';
import '../../../repositories/voip.dart';
import '../../../use_case.dart';
import '../../metrics/track_toggle_mute.dart';

class ToggleMuteVoipCallUseCase extends FutureUseCase<void> {
  final _voipRepository = dependencyLocator<VoipRepository>();
  final _trackToggleMute = TrackToggleMuteUseCase();

  @override
  Future<void> call() async {
    _trackToggleMute();
    await _voipRepository.toggleMute();
  }
}

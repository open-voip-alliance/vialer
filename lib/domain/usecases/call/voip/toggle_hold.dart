import '../../../../dependency_locator.dart';
import '../../../repositories/voip.dart';
import '../../../use_case.dart';
import '../../metrics/track_toggle_hold.dart';

class ToggleHoldVoipCallUseCase extends UseCase {
  final _voipRepository = dependencyLocator<VoipRepository>();
  final _trackToggleHold = TrackToggleHoldUseCase();

  Future<void> call() async {
    _trackToggleHold();
    await _voipRepository.toggleHold();
  }
}

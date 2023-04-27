import 'dart:async';

import '../../../../dependency_locator.dart';
import '../../metrics/track_toggle_hold.dart';
import '../../use_case.dart';
import 'voip.dart';

class ToggleHoldVoipCallUseCase extends UseCase {
  final _voipRepository = dependencyLocator<VoipRepository>();
  final _trackToggleHold = TrackToggleHoldUseCase();

  Future<void> call() async {
    unawaited(_trackToggleHold());
    await _voipRepository.toggleHold();
  }
}

import 'dart:async';

import '../../../../../dependency_locator.dart';
import '../../../../data/repositories/calling/voip/voip.dart';
import '../../metrics/track_toggle_hold.dart';
import '../../use_case.dart';

class ToggleHoldVoipCallUseCase extends UseCase {
  final _voipRepository = dependencyLocator<VoipRepository>();
  final _trackToggleHold = TrackToggleHoldUseCase();

  Future<void> call() async {
    _trackToggleHold();
    await _voipRepository.toggleHold();
  }
}

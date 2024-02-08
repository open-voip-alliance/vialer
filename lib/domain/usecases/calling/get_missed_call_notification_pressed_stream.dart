import 'dart:async';

import '../../../data/repositories/calling/voip/voip.dart';
import '../../../dependency_locator.dart';
import '../use_case.dart';

class GetMissedCallNotificationPressedStream extends UseCase {
  final _voipRepository = dependencyLocator<VoipRepository>();

  Stream<bool> call() => _voipRepository.missedCallNotificationPresses;
}

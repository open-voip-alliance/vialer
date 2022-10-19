import 'dart:async';

import '../../dependency_locator.dart';
import '../use_case.dart';
import 'voip/voip.dart';

class GetMissedCallNotificationPressedStream extends UseCase {
  final _voipRepository = dependencyLocator<VoipRepository>();

  Stream<bool> call() => _voipRepository.missedCallNotificationPresses;
}

import 'dart:async';

import '../../../../data/repositories/calling/voip/voip.dart';
import '../../../../dependency_locator.dart';
import '../../use_case.dart';

class GetHasVoipStartedUseCase extends UseCase {
  final _voipRepository = dependencyLocator<VoipRepository>();

  Future<bool> call() => _voipRepository.hasStarted;
}

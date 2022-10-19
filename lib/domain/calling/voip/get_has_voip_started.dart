import 'dart:async';

import '../../../dependency_locator.dart';
import '../../use_case.dart';
import 'voip.dart';

class GetHasVoipStartedUseCase extends UseCase {
  final _voipRepository = dependencyLocator<VoipRepository>();

  Future<bool> call() => _voipRepository.hasStarted;
}

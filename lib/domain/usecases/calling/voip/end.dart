import 'dart:async';

import '../../../../../dependency_locator.dart';
import '../../../../data/repositories/calling/voip/voip.dart';
import '../../use_case.dart';

class EndVoipCallUseCase extends UseCase {
  final _voipRepository = dependencyLocator<VoipRepository>();

  Future<void> call() => _voipRepository.endCall();
}

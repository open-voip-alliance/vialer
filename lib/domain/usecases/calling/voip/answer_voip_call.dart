import 'dart:async';

import '../../../../data/repositories/calling/voip/voip.dart';
import '../../../../dependency_locator.dart';
import '../../use_case.dart';

class AnswerVoipCallUseCase extends UseCase {
  final _voipRepository = dependencyLocator<VoipRepository>();

  Future<void> call() => _voipRepository.answerCall();
}

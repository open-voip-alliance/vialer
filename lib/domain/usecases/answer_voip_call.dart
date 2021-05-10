import 'dart:async';

import '../../dependency_locator.dart';
import '../repositories/voip.dart';
import '../use_case.dart';

class AnswerVoipCallUseCase extends UseCase {
  final _voipRepository = dependencyLocator<VoipRepository>();

  Future<void> call() => _voipRepository.answerCall();
}

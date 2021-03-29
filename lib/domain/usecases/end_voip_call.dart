import 'dart:async';

import '../../dependency_locator.dart';
import '../repositories/voip.dart';
import '../use_case.dart';

class EndVoipCallUseCase extends FutureUseCase<void> {
  final _voipRepository = dependencyLocator<VoipRepository>();

  @override
  Future<void> call() => _voipRepository.endCall();
}

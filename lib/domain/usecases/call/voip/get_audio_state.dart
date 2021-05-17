import 'package:flutter_phone_lib/audio/audio_state.dart';

import '../../../../dependency_locator.dart';
import '../../../repositories/voip.dart';
import '../../../use_case.dart';

class GetVoipCallAudioStateUseCase extends UseCase {
  final _voipRepository = dependencyLocator<VoipRepository>();

  Future<AudioState> call() => _voipRepository.audioState;
}

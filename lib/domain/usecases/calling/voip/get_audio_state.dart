import 'package:flutter_phone_lib/flutter_phone_lib.dart';

import '../../../../../dependency_locator.dart';
import '../../../../data/repositories/calling/voip/voip.dart';
import '../../use_case.dart';

class GetVoipCallAudioStateUseCase extends UseCase {
  final _voipRepository = dependencyLocator<VoipRepository>();

  Future<AudioState> call() => _voipRepository.audioState;
}

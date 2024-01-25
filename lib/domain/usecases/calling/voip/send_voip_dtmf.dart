import 'dart:async';

import '../../../../data/repositories/calling/voip/voip.dart';
import '../../../../dependency_locator.dart';
import '../../use_case.dart';

class SendVoipDtmfUseCase extends UseCase {
  final _voipRepository = dependencyLocator<VoipRepository>();

  Future<void> call({required String dtmf}) => _voipRepository.sendDtmf(dtmf);
}

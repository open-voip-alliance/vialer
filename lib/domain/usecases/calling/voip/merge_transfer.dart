import 'dart:async';

import '../../../../../dependency_locator.dart';
import '../../../../data/repositories/calling/voip/voip.dart';
import '../../../../global.dart';
import '../../use_case.dart';

class MergeTransferUseCase extends UseCase {
  final _voipRepository = dependencyLocator<VoipRepository>();

  Future<void> call() async {
    _voipRepository.mergeTransferCalls();
    track('call-transfer-completed');
  }
}

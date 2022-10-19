import 'dart:async';

import '../../../../dependency_locator.dart';
import '../../use_case.dart';
import 'voip.dart';

class MergeTransferUseCase extends UseCase {
  final _voipRepository = dependencyLocator<VoipRepository>();

  Future<void> call() => _voipRepository.mergeTransferCalls();
}

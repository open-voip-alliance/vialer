import 'dart:async';

import '../../../../dependency_locator.dart';
import '../../use_case.dart';
import 'voip.dart';

class BeginTransferUseCase extends UseCase {
  final _voipRepository = dependencyLocator<VoipRepository>();

  Future<void> call({required String number}) =>
      _voipRepository.beginTransfer(number);
}

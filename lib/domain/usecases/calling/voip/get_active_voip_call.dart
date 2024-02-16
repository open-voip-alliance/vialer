import 'dart:async';

import 'package:flutter_phone_lib/flutter_phone_lib.dart';

import '../../../../data/repositories/calling/voip/voip.dart';
import '../../../../dependency_locator.dart';
import '../../use_case.dart';

class GetActiveVoipCall extends UseCase {
  final _voipRepository = dependencyLocator<VoipRepository>();

  Future<Call?> call() => _voipRepository.activeCall;
}

import 'dart:async';

import 'package:flutter_phone_lib/flutter_phone_lib.dart';

import '../../../dependency_locator.dart';
import '../../use_case.dart';
import 'voip.dart';

class GetActiveVoipCall extends UseCase {
  final _voipRepository = dependencyLocator<VoipRepository>();

  Future<Call?> call() => _voipRepository.activeCall;
}

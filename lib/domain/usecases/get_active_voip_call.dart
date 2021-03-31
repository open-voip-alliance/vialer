import 'dart:async';

import 'package:flutter_phone_lib/flutter_phone_lib.dart';

import '../../dependency_locator.dart';
import '../repositories/voip.dart';
import '../use_case.dart';

class GetActiveVoipCall extends FutureUseCase<Call> {
  final _voipRepository = dependencyLocator<VoipRepository>();

  @override
  Future<Call> call() => _voipRepository.activeCall;
}

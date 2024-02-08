import 'dart:async';

import 'package:flutter_phone_lib/flutter_phone_lib.dart';

import '../../../../data/repositories/calling/voip/voip.dart';
import '../../../../dependency_locator.dart';
import '../../use_case.dart';

class GetVoipCallEventStreamUseCase extends UseCase {
  final _voipRepository = dependencyLocator<VoipRepository>();

  Stream<Event> call() async* {
    await _voipRepository.hasStarted;

    yield* _voipRepository.events;
  }
}

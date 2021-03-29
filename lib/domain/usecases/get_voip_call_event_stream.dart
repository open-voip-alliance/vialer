import 'dart:async';

import 'package:flutter_phone_lib/flutter_phone_lib.dart';

import '../../dependency_locator.dart';
import '../repositories/voip.dart';
import '../use_case.dart';

class GetVoipCallEventStream extends UseCase<Stream<Event>> {
  final _voipRepository = dependencyLocator<VoipRepository>();

  @override
  Stream<Event> call() async* {
    await _voipRepository.hasStarted;

    yield* _voipRepository.events;
  }
}

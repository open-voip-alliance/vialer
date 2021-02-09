import 'dart:async';

import 'package:voip_flutter_integration/events/event.dart';

import '../../dependency_locator.dart';
import '../repositories/voip.dart';
import '../use_case.dart';

class GetCallEventStream extends UseCase<Stream<Event>> {
  final _voipRepository = dependencyLocator<VoipRepository>();

  @override
  Stream<Event> call() => _voipRepository.events;
}

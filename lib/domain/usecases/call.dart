import 'dart:async';

import 'package:meta/meta.dart';

import '../../dependency_locator.dart';
import '../repositories/call_through.dart';
import '../repositories/voip.dart';
import '../use_case.dart';

class CallUseCase extends FutureUseCase<void> {
  final _callThroughRepository = dependencyLocator<CallThroughRepository>();
  final _voipRepository = dependencyLocator<VoipRepository>();

  @override
  Future<void> call({
    @required String destination,
    @required bool useVoip,
  }) =>
      useVoip
          // TODO: Should probably be handled in the PIL.
          ? _voipRepository.call(destination.replaceAll(RegExp(r'\s'), ''))
          : _callThroughRepository.call(destination);
}

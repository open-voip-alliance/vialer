import 'dart:async';

import 'package:meta/meta.dart';

import '../../dependency_locator.dart';
import '../repositories/call.dart';
import '../use_case.dart';

class CallUseCase extends FutureUseCase<void> {
  final _callRepository = dependencyLocator<CallRepository>();

  @override
  Future<void> call({
    @required String destination,
    @required bool useVoip,
  }) async {
    // TODO: Support VoIP.
    if (useVoip) {
      return;
    }

    await _callRepository.call(destination);
  }
}

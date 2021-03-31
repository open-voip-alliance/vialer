import 'dart:async';

import 'package:meta/meta.dart';

import '../../../dependency_locator.dart';
import '../../repositories/call_through.dart';
import '../../repositories/storage.dart';
import '../../repositories/voip.dart';
import '../../use_case.dart';
import '../get_user.dart';

class CallUseCase extends FutureUseCase<void> {
  final _callThroughRepository = dependencyLocator<CallThroughRepository>();
  final _voipRepository = dependencyLocator<VoipRepository>();
  final _storageRepository = dependencyLocator<StorageRepository>();

  final _getUser = GetUserUseCase();

  @override
  Future<void> call({
    @required String destination,
    @required bool useVoip,
  }) async {
    if (useVoip) {
      // TODO: Unify number normalization
      await _voipRepository.call(destination.replaceAll(RegExp(r'\s'), ''));
    } else {
      final user = await _getUser(latest: false);
      await _callThroughRepository.call(destination, user: user);
    }

    _storageRepository.lastDialedNumber = destination;
  }
}

import 'dart:async';

import '../../../dependency_locator.dart';
import '../../repositories/call_through.dart';
import '../../repositories/storage.dart';
import '../../repositories/voip.dart';
import '../../use_case.dart';
import '../clear_call_through_region_number.dart';
import '../get_call_through_region_number.dart';
import '../get_logged_in_user.dart';

class CallUseCase extends UseCase {
  final _callThroughRepository = dependencyLocator<CallThroughRepository>();
  final _voipRepository = dependencyLocator<VoipRepository>();
  final _storageRepository = dependencyLocator<StorageRepository>();

  final _getUser = GetLoggedInUserUseCase();
  final _getCallThroughRegionNumber = GetCallThroughRegionNumberUseCase();
  final _clearCallThroughRegionNumber = ClearCallThroughRegionNumberUseCase();

  Future<void> call({
    required String destination,
    required bool useVoip,
  }) async {
    if (useVoip) {
      await _voipRepository.call(destination);
    } else {
      final user = _getUser();
      final regionNumber = await _getCallThroughRegionNumber(
        destination: destination,
      );

      await _callThroughRepository(destination, regionNumber, user: user);

      _clearCallThroughRegionNumber();
    }

    _storageRepository.lastDialedNumber = destination;
  }
}

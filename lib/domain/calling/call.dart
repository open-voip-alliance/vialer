import 'dart:async';

import '../../../dependency_locator.dart';
import '../legacy/storage.dart';
import '../use_case.dart';
import '../user/get_logged_in_user.dart';
import 'call_through/call_through.dart';
import 'call_through/clear_call_through_region_number.dart';
import 'call_through/get_call_through_region_number.dart';
import 'voip/voip.dart';

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
    final numberToCall = destination.normalizedForCalling;

    if (useVoip) {
      await _voipRepository.call(numberToCall);
    } else {
      await _callThroughRepository(
        numberToCall,
        await _getCallThroughRegionNumber(destination: destination),
        user: _getUser(),
      );

      _clearCallThroughRegionNumber();
    }

    _storageRepository.lastDialedNumber = destination;
  }
}

extension on String {
  String get normalizedForCalling => replaceAll(RegExp('[-()]'), '');
}

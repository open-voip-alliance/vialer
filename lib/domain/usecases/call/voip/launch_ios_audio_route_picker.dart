import 'dart:io';

import '../../../../dependency_locator.dart';
import '../../../repositories/voip.dart';
import '../../../use_case.dart';

class LaunchIOSAudioRoutePickerUseCase extends UseCase {
  final _voipRepository = dependencyLocator<VoipRepository>();

  Future<void> call() async {
    assert(Platform.isIOS);
    await _voipRepository.launchAudioRoutePicker();
  }
}

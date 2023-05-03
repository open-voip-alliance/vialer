import 'dart:io';

import '../../../../dependency_locator.dart';
import '../../use_case.dart';
import 'voip.dart';

class LaunchIOSAudioRoutePickerUseCase extends UseCase {
  final _voipRepository = dependencyLocator<VoipRepository>();

  Future<void> call() async {
    assert(Platform.isIOS, 'iOS audio route picker only works on iOS');
    await _voipRepository.launchAudioRoutePicker();
  }
}

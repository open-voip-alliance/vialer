import 'package:flutter_phone_lib/audio/audio_route.dart';
import 'package:flutter_phone_lib/audio/bluetooth_audio_route.dart';

import '../../../../dependency_locator.dart';
import '../../../repositories/voip.dart';
import '../../../use_case.dart';
import '../../metrics/track_route_audio.dart';

class RouteAudioToBluetoothDeviceUseCase extends UseCase {
  final _voipRepository = dependencyLocator<VoipRepository>();
  final _trackRouteAudio = TrackRouteAudioUseCase();

  Future<void> call({required BluetoothAudioRoute route}) async {
    _trackRouteAudio(
      route: AudioRoute.bluetooth,
      bluetoothDevice: route.identifier,
    );

    await _voipRepository.routeAudioToBluetoothDevice(route);
  }
}

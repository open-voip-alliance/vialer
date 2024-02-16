import 'dart:async';

import 'package:flutter_phone_lib/flutter_phone_lib.dart';

import '../../../../../dependency_locator.dart';
import '../../../../data/repositories/calling/voip/voip.dart';
import '../../../usecases/metrics/track_route_audio.dart';
import '../../use_case.dart';

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

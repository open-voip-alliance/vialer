import 'package:flutter/material.dart';
import 'package:flutter_phone_lib/audio/audio_route.dart';
import 'package:flutter_phone_lib/audio/audio_state.dart';
import 'package:flutter_phone_lib/audio/bluetooth_audio_route.dart';
import 'package:intl/intl.dart';

import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';

class AudioRoutePicker extends StatelessWidget {
  final AudioState audioState;

  const AudioRoutePicker({
    required this.audioState,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      children: <Widget>[
        _AudioRouteDialogOption(
          route: AudioRoute.phone,
          currentRoute: audioState.currentRoute,
          icon: const Icon(VialerSans.phone),
          label: context.msg.main.call.actions.phone,
        ),
        _AudioRouteDialogOption(
          route: AudioRoute.speaker,
          currentRoute: audioState.currentRoute,
          icon: const Icon(VialerSans.speaker),
          label: context.msg.main.call.actions.speaker,
        ),
        ..._buildBluetoothOptions(
          context: context,
          audioState: audioState,
        ),
      ],
    );
  }

  List<_AudioRouteDialogOption> _buildBluetoothOptions({
    required BuildContext context,
    required AudioState audioState,
  }) {
    if (audioState.bluetoothRoutes.length <= 1) {
      return [
        _AudioRouteDialogOption(
          route: AudioRoute.bluetooth,
          currentRoute: audioState.currentRoute,
          icon: const Icon(VialerSans.bluetooth),
          label: _bluetoothLabelFor(
            context: context,
            bluetoothDeviceName: audioState.bluetoothDeviceName ?? '',
          ),
        ),
      ];
    }

    return audioState.bluetoothRoutes
        .map(
          (route) => _AudioRouteDialogOption(
            route: route,
            currentRoute: BluetoothAudioRoute(
              displayName: audioState.bluetoothDeviceName ?? '',
              identifier: audioState.bluetoothDeviceName ?? '',
            ),
            icon: const Icon(VialerSans.bluetooth),
            label: route.displayName,
          ),
        )
        .toList();
  }

  String _bluetoothLabelFor({
    required BuildContext context,
    required String bluetoothDeviceName,
  }) {
    final label = context.msg.main.call.actions.bluetooth;

    return toBeginningOfSentenceCase(
      bluetoothDeviceName.isNotEmpty ? '$label ($bluetoothDeviceName)' : label,
    )!;
  }
}

class _AudioRouteDialogOption extends StatelessWidget {
  final Object route;
  final Object currentRoute;
  final Widget icon;
  final String label;

  const _AudioRouteDialogOption({
    required this.route,
    required this.currentRoute,
    required this.icon,
    required this.label,
  })  : assert(route is AudioRoute || route is BluetoothAudioRoute),
        assert(
          currentRoute is AudioRoute || currentRoute is BluetoothAudioRoute,
        );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SimpleDialogOption(
        onPressed: () => Navigator.pop(context, route),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: icon,
            ),
            Text(
              toBeginningOfSentenceCase(
                label,
              )!,
            ),
            const Spacer(),
            if (_isCurrentRoute()) const Icon(VialerSans.check),
          ],
        ),
      ),
    );
  }

  bool _isCurrentRoute() {
    if (route is BluetoothAudioRoute && currentRoute is BluetoothAudioRoute) {
      return (route as BluetoothAudioRoute).identifier ==
          (currentRoute as BluetoothAudioRoute).identifier;
    }

    return currentRoute == route;
  }
}

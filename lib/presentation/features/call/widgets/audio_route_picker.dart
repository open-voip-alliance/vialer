import 'package:flutter/material.dart';
import 'package:flutter_phone_lib/flutter_phone_lib.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:vialer/presentation/resources/localizations.dart';
import 'package:vialer/presentation/resources/theme.dart';

class AudioRoutePicker extends StatelessWidget {
  const AudioRoutePicker({
    required this.audioState,
    super.key,
  });

  final AudioState audioState;

  @override
  Widget build(BuildContext context) {
    return IconTheme.merge(
      data: IconThemeData(
        color: context.brand.theme.colors.grey6,
      ),
      child: SimpleDialog(
        children: <Widget>[
          _AudioRouteDialogOption(
            route: AudioRoute.phone,
            currentRoute: audioState.currentRoute,
            icon: const FaIcon(FontAwesomeIcons.phone),
            label: context.msg.main.call.ongoing.actions.audioRoute.phone,
          ),
          _AudioRouteDialogOption(
            route: AudioRoute.speaker,
            currentRoute: audioState.currentRoute,
            icon: const FaIcon(FontAwesomeIcons.volume),
            label: context.msg.main.call.ongoing.actions.audioRoute.speaker,
          ),
          ..._buildBluetoothOptions(
            context: context,
            audioState: audioState,
          ),
        ],
      ),
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
          icon: const FaIcon(FontAwesomeIcons.bluetooth),
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
            icon: const FaIcon(FontAwesomeIcons.bluetooth),
            label: route.displayName,
          ),
        )
        .toList();
  }

  String _bluetoothLabelFor({
    required BuildContext context,
    required String bluetoothDeviceName,
  }) {
    final label = context.msg.main.call.ongoing.actions.audioRoute.bluetooth;

    return toBeginningOfSentenceCase(
      bluetoothDeviceName.isNotEmpty ? '$label ($bluetoothDeviceName)' : label,
    )!;
  }
}

class _AudioRouteDialogOption extends StatelessWidget {
  const _AudioRouteDialogOption({
    required this.route,
    required this.currentRoute,
    required this.icon,
    required this.label,
  })  : assert(
          route is AudioRoute || route is BluetoothAudioRoute,
          'route must be eiter AudioRoute or BluetoothAudioRoute',
        ),
        assert(
          currentRoute is AudioRoute || currentRoute is BluetoothAudioRoute,
          'currentRoute must be eiter AudioRoute or BluetoothAudioRoute',
        );
  final Object route;
  final Object currentRoute;
  final Widget icon;
  final String label;

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
            Expanded(
              child: Text(
                toBeginningOfSentenceCase(
                  label,
                )!,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (_isCurrentRoute()) const FaIcon(FontAwesomeIcons.check),
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

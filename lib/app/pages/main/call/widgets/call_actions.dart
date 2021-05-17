import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phone_lib/audio/audio_route.dart';
import 'package:flutter_phone_lib/audio/audio_state.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';
import '../../../../util/brand.dart';
import '../../widgets/caller.dart';
import '../../widgets/dial_pad/keypad.dart';
import '../../widgets/dial_pad/widget.dart';
import '../widgets/call_button.dart';

class CallActions extends StatefulWidget {
  final void Function(Duration) popAfter;

  const CallActions({
    Key? key,
    required this.popAfter,
  }) : super(key: key);

  @override
  _CallActionsState createState() => _CallActionsState();
}

class _CallActionsState extends State<CallActions> {
  static const _actionsRoute = 'actions';
  static const _dialPadRouteName = 'dial-pad';

  final _navigatorKey = GlobalKey<NavigatorState>();

  NavigatorState get _navigatorState => _navigatorKey.currentState!;

  final _dialPadController = TextEditingController();
  late String _latestDialPadValue;

  void _hangUp() {
    context.read<CallerCubit>().endVoipCall();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _dialPadController.addListener(() {
      final currentDialPadValue = _dialPadController.value.text;

      if (currentDialPadValue != _latestDialPadValue) {
        context
            .read<CallerCubit>()
            .sendVoipDtmf(currentDialPadValue.characters.last);
        _latestDialPadValue = currentDialPadValue;
      }
    });
  }

  // Since the nested navigator cannot capture the back button press (Android),
  // we use WillPopScope to capture that event, and pop the nested navigator
  // route if possible.
  Future<bool> _onWillPop(BuildContext context) {
    if (_navigatorState.canPop()) {
      _navigatorState.pop();
      return SynchronousFuture(false);
    }

    return SynchronousFuture(true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: HeroControllerScope(
        controller: MaterialApp.createMaterialHeroController(),
        // We use a Navigator to have a smooth movement transition between the
        // hang up buttons using Hero animations, instead of having it look
        // like there are 2 hang up buttons during the transition.
        child: Navigator(
          key: _navigatorKey,
          initialRoute: _actionsRoute,
          onGenerateRoute: (settings) {
            final routeName = settings.name;

            if (routeName == _actionsRoute) {
              return MaterialPageRoute(builder: (context) {
                return _CallActionButtons(
                  onHangUpButtonPressed: _hangUp,
                );
              });
            } else if (routeName == _dialPadRouteName) {
              return MaterialPageRoute(builder: (context) {
                return _DialPad(
                  dialPadController: _dialPadController,
                  onHangUpButtonPressed: _hangUp,
                  onCancelButtonPressed: _navigatorState.pop,
                );
              });
            }

            throw StateError('Unknown route: $routeName');
          },
        ),
      ),
    );
  }
}

class _CallActionButtons extends StatelessWidget {
  final void Function() onHangUpButtonPressed;

  const _CallActionButtons({
    Key? key,
    required this.onHangUpButtonPressed,
  }) : super(key: key);

  void _toggleMute(BuildContext context) =>
      context.read<CallerCubit>().toggleMute();

  void _toggleDialPad(BuildContext context) {
    Navigator.pushNamed(context, 'dial-pad');
  }

  void _transfer() {}

  void _toggleHold(BuildContext context) =>
      context.read<CallerCubit>().toggleHoldVoipCall();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CallerCubit, CallerState>(
      builder: (context, state) {
        final processState = state as CallProcessState;
        final call = processState.voipCall!;

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: const Icon(VialerSans.mute),
                    text: Text(context.msg.main.call.actions.mute),
                    active: processState.isVoipCallMuted,
                    // We can't mute when on hold.
                    onPressed:
                        !call.isOnHold ? () => _toggleMute(context) : null,
                  ),
                ),
                Expanded(
                  child: _ActionButton(
                    icon: const Icon(VialerSans.dialpad),
                    text: Text(context.msg.main.call.actions.keypad),
                    onPressed: () => _toggleDialPad(context),
                  ),
                ),
                const Expanded(
                  child: _AudioRouteButton(),
                ),
              ],
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Spacer(),
                Expanded(
                  flex: 2,
                  child: _ActionButton(
                    icon: const Icon(VialerSans.transfer),
                    text: Text(context.msg.main.call.actions.transfer),
                    onPressed: _transfer,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: _ActionButton(
                    icon: const Icon(VialerSans.onHold),
                    text: Text(context.msg.main.call.actions.hold),
                    active: call.isOnHold,
                    onPressed: () => _toggleHold(context),
                  ),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 48),
            Center(
              child: CallButton.hangUp(
                onPressed:
                    state is! FinishedCalling ? onHangUpButtonPressed : null,
              ),
            ),
            const SizedBox(height: 32),
          ],
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final Widget icon;
  final Widget text;

  final bool active;

  final VoidCallback? onPressed;

  const _ActionButton({
    Key? key,
    required this.icon,
    required this.text,
    this.active = false,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = onPressed != null
        ? context.brand.theme.grey6
        : context.brand.theme.grey4;

    const iconSize = 64.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: iconSize,
          width: iconSize,
          child: Material(
            shape: const CircleBorder(),
            color: active
                ? context.brand.theme.primary
                : context.brand.theme.primary.withOpacity(0),
            child: InkResponse(
              onTap: onPressed,
              containedInkWell: active,
              radius: active ? iconSize : iconSize / 2,
              customBorder: const CircleBorder(),
              child: IconTheme.merge(
                data: IconThemeData(
                  size: 32,
                  color: active ? context.brand.theme.onPrimaryColor : color,
                ),
                child: icon,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        DefaultTextStyle.merge(
          style: TextStyle(
            fontSize: 16,
            color: color,
          ),
          child: text,
        ),
      ],
    );
  }
}

class _AudioRouteButton extends StatelessWidget {
  const _AudioRouteButton();

  Future<void> _showAudioPopupMenu(
    BuildContext context,
    AudioState? audioState,
  ) async {
    final bluetoothDeviceName = audioState?.bluetoothDeviceName ?? '';
    final currentRoute = audioState?.currentRoute ?? AudioRoute.phone;

    final selectedRoute = await showDialog<AudioRoute>(
        context: context,
        builder: (context) {
          return SimpleDialog(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, AudioRoute.phone),
                  child: Row(
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Icon(VialerSans.phone),
                      ),
                      Text(
                        toBeginningOfSentenceCase(
                          context.msg.main.call.actions.phone,
                        )!,
                      ),
                      const Spacer(),
                      if (currentRoute == AudioRoute.phone)
                        const Icon(VialerSans.check)
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, AudioRoute.speaker),
                  child: Row(
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Icon(VialerSans.speaker),
                      ),
                      Text(
                        toBeginningOfSentenceCase(
                          context.msg.main.call.actions.speaker,
                        )!,
                      ),
                      const Spacer(),
                      if (currentRoute == AudioRoute.speaker)
                        const Icon(VialerSans.check)
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, AudioRoute.bluetooth),
                  child: Row(
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Icon(VialerSans.bluetooth),
                      ),
                      Text(
                        _bluetoothLabelFor(
                          context: context,
                          bluetoothDeviceName: bluetoothDeviceName,
                        ),
                      ),
                      const Spacer(),
                      if (currentRoute == AudioRoute.bluetooth)
                        const Icon(VialerSans.check)
                    ],
                  ),
                ),
              ),
            ],
          );
        });

    if (selectedRoute != null) {
      context.read<CallerCubit>().routeAudio(selectedRoute);
    }
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

  IconData _iconFor({
    required BuildContext context,
    required bool hasBluetooth,
    required AudioRoute currentRoute,
  }) {
    if (!hasBluetooth || currentRoute == AudioRoute.speaker) {
      return VialerSans.speaker;
    }

    if (currentRoute == AudioRoute.bluetooth) {
      return VialerSans.bluetooth;
    }

    return VialerSans.phone;
  }

  String _labelFor({
    required BuildContext context,
    required bool hasBluetooth,
    required AudioRoute currentRoute,
    required String bluetoothDeviceName,
  }) {
    if (!hasBluetooth || currentRoute == AudioRoute.speaker) {
      return context.msg.main.call.actions.speaker;
    }

    if (currentRoute == AudioRoute.bluetooth) {
      return bluetoothDeviceName.isNotEmpty
          ? bluetoothDeviceName
          : context.msg.main.call.actions.bluetooth;
    }

    return context.msg.main.call.actions.phone;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CallerCubit, CallerState>(builder: (context, state) {
      final processState = state as CallProcessState;

      final currentRoute =
          processState.audioState?.currentRoute ?? AudioRoute.phone;
      final hasBluetooth = processState.audioState != null &&
          processState.audioState!.availableRoutes
              .contains(AudioRoute.bluetooth);

      return _ActionButton(
        icon: Icon(
          _iconFor(
            context: context,
            hasBluetooth: hasBluetooth,
            currentRoute: currentRoute,
          ),
        ),
        text: Text(
          _labelFor(
            context: context,
            hasBluetooth: hasBluetooth,
            currentRoute: currentRoute,
            bluetoothDeviceName:
                processState.audioState?.bluetoothDeviceName ?? '',
          ),
        ),
        active: !hasBluetooth && (currentRoute == AudioRoute.speaker),
        onPressed: () {
          if (processState.audioState != null && hasBluetooth) {
            _showAudioPopupMenu(context, processState.audioState);
          } else {
            context.read<CallerCubit>().routeAudio(
                  currentRoute == AudioRoute.phone
                      ? AudioRoute.speaker
                      : AudioRoute.phone,
                );
          }
        },
      );
    });
  }
}

class _DialPad extends StatelessWidget {
  final TextEditingController dialPadController;
  final VoidCallback onHangUpButtonPressed;
  final VoidCallback onCancelButtonPressed;

  const _DialPad({
    Key? key,
    required this.dialPadController,
    required this.onHangUpButtonPressed,
    required this.onCancelButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CallerCubit, CallerState>(
      builder: (context, state) {
        final processState = state as CallProcessState;

        return Material(
          child: DialPad(
            controller: dialPadController,
            canDelete: false,
            primaryButton: CallButton.hangUp(
              onPressed: processState is! FinishedCalling
                  ? onHangUpButtonPressed
                  : null,
            ),
            secondaryButton: KeypadButton(
              borderOnIos: false,
              child: InkResponse(
                onTap: onCancelButtonPressed,
                child: Icon(
                  VialerSans.close,
                  color: context.brand.theme.grey5,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

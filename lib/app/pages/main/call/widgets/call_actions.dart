import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phone_lib/flutter_phone_lib.dart';

import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';
import '../../widgets/caller.dart';
import '../../widgets/dial_pad/keypad.dart';
import '../../widgets/dial_pad/widget.dart';
import '../../widgets/nested_navigator.dart';
import '../widgets/call_button.dart';
import 'audio_route_picker.dart';
import 'call_process_state_builder.dart';

class CallActions extends StatefulWidget {
  /// Invoked when the transfer button is pressed. The call will always be
  /// put on hold.
  final VoidCallback onTransferButtonPressed;

  final GlobalKey<NavigatorState>? navigatorKey;

  const CallActions({
    Key? key,
    this.navigatorKey,
    required this.onTransferButtonPressed,
  }) : super(key: key);

  @override
  _CallActionsState createState() => _CallActionsState();
}

class _CallActionsState extends State<CallActions> {
  static const _actionsRoute = 'actions';
  static const _dialPadRoute = 'dial-pad';

  final _dialPadController = TextEditingController();
  var _latestDialPadValue = '';

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

  @override
  Widget build(BuildContext context) {
    // We use a Navigator to have a smooth movement transition between the
    // hang up buttons using Hero animations, instead of having it look
    // like there are 2 hang up buttons during the transition.
    return NestedNavigator(
      navigatorKey: widget.navigatorKey,
      fullscreenDialog: true,
      routes: {
        _actionsRoute: (context, _) {
          return _CallActionButtons(
            onHangUpButtonPressed: _hangUp,
            onTransferButtonPressed: widget.onTransferButtonPressed,
          );
        },
        _dialPadRoute: (context, _) {
          return _DialPad(
            dialPadController: _dialPadController,
            onHangUpButtonPressed: _hangUp,
            onCancelButtonPressed: () => Navigator.pop(context),
          );
        }
      },
    );
  }
}

class _CallActionButtons extends StatelessWidget {
  final VoidCallback onHangUpButtonPressed;
  final VoidCallback onTransferButtonPressed;

  const _CallActionButtons({
    Key? key,
    required this.onHangUpButtonPressed,
    required this.onTransferButtonPressed,
  }) : super(key: key);

  void _toggleMute(BuildContext context) =>
      context.read<CallerCubit>().toggleMute();

  void _toggleDialPad(BuildContext context) {
    Navigator.pushNamed(context, 'dial-pad');
  }

  void _transfer(BuildContext context) {
    // We delay the hold by 500ms, because currently holding a call causes
    // a significant frame drop which would be very noticeable during the
    // transition animation.
    //
    // See #955 (https://gitlab.wearespindle.com/vialer/mobile/app/-/issues/955)
    Future.delayed(const Duration(milliseconds: 500), () {
      _hold(context);
    });
    onTransferButtonPressed();
  }

  void _merge(BuildContext context) =>
      context.read<CallerCubit>().mergeTransfer();

  void _toggleHold(BuildContext context) =>
      context.read<CallerCubit>().toggleHoldVoipCall();

  void _hold(BuildContext context) =>
      context.read<CallerCubit>().holdVoipCall();

  @override
  Widget build(BuildContext context) {
    return CallProcessStateBuilder(
      builder: (context, state) {
        final call = state.voipCall!;

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: const Icon(VialerSans.mute),
                    text: Text(
                      context.msg.main.call.ongoing.actions.mute,
                      textAlign: TextAlign.center,
                    ),
                    active: state.isVoipCallMuted,
                    // We can't mute when on hold.
                    onPressed: !call.isOnHold && !state.isFinished
                        ? () => _toggleMute(context)
                        : null,
                  ),
                ),
                Expanded(
                  child: _ActionButton(
                    icon: const Icon(VialerSans.dialpad),
                    text: Text(
                      context.msg.main.call.ongoing.actions.keypad,
                      textAlign: TextAlign.center,
                    ),
                    onPressed: !state.isFinished
                        ? () => _toggleDialPad(context)
                        : null,
                  ),
                ),
                Expanded(
                  child: _AudioRouteButton(
                    enabled: !state.isFinished,
                  ),
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
                    icon: state.isInTransfer
                        ? const Icon(VialerSans.merge)
                        : const Icon(VialerSans.transfer),
                    text: Text(
                      state.isInTransfer
                          ? context.msg.main.call.ongoing.actions.merge
                          : context.msg.main.call.ongoing.actions.transfer,
                      textAlign: TextAlign.center,
                    ),
                    onPressed: state.isActionable
                        ? () => state.isInTransfer
                            ? _merge(context)
                            : _transfer(context)
                        : null,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: _ActionButton(
                    icon: const Icon(VialerSans.onHold),
                    text: Text(
                      context.msg.main.call.ongoing.actions.hold,
                      textAlign: TextAlign.center,
                    ),
                    active: call.isOnHold,
                    onPressed:
                        state.isActionable ? () => _toggleHold(context) : null,
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
  final VoidCallback? onPressed;

  /// An active button is one that is currently in-use, so for example the
  /// hold button would be active if the call is current on-hold.
  final bool active;

  /// An enabled button is available to be pressed by the user, for example
  /// if the call is not yet connected, the user cannot transfer that call so
  /// the button will not be enabled.
  bool get _enabled => onPressed != null;

  const _ActionButton({
    Key? key,
    required this.icon,
    required this.text,
    this.active = false,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                ? context.brand.theme.colors.primary
                : context.brand.theme.colors.primary.withOpacity(0),
            child: InkResponse(
              onTap: _enabled ? onPressed : null,
              containedInkWell: active,
              radius: active ? iconSize : iconSize / 2,
              customBorder: const CircleBorder(),
              child: IconTheme.merge(
                data: IconThemeData(
                  size: 32,
                  color: _pickIconColor(context),
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
            color: _pickTextColor(context),
          ),
          child: text,
        ),
      ],
    );
  }

  Color _pickTextColor(BuildContext context) => _enabled
      ? context.brand.theme.colors.grey6
      : context.brand.theme.colors.grey2;

  Color _pickIconColor(BuildContext context) {
    if (active) return context.brand.theme.colors.onPrimary;

    if (!_enabled) return context.brand.theme.colors.grey2;

    return context.brand.theme.colors.grey6;
  }
}

class _AudioRouteButton extends StatelessWidget {
  final bool enabled;

  const _AudioRouteButton({
    this.enabled = true,
  });

  Future<void> _showAudioPopupMenu(
    BuildContext context,
    AudioState? audioState,
  ) async {
    if (Platform.isIOS) {
      context.read<CallerCubit>().launchIOSAudioRoutePicker();
      return;
    }

    final selectedRoute = await showDialog<dynamic>(
      context: context,
      builder: (context) {
        return AudioRoutePicker(
          audioState: audioState!,
        );
      },
    );

    if (selectedRoute is AudioRoute) {
      context.read<CallerCubit>().routeAudio(selectedRoute);
    } else if (selectedRoute is BluetoothAudioRoute) {
      context.read<CallerCubit>().routeAudioToBluetoothDevice(selectedRoute);
    }
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
      return context.msg.main.call.ongoing.actions.speaker;
    }

    if (currentRoute == AudioRoute.bluetooth) {
      return bluetoothDeviceName.isNotEmpty
          ? bluetoothDeviceName
          : context.msg.main.call.ongoing.actions.bluetooth;
    }

    return context.msg.main.call.ongoing.actions.phone;
  }

  @override
  Widget build(BuildContext context) {
    return CallProcessStateBuilder(
      builder: (context, state) {
        final currentRoute = state.audioState?.currentRoute ?? AudioRoute.phone;
        final hasBluetooth = state.audioState != null &&
            state.audioState!.availableRoutes.contains(AudioRoute.bluetooth);

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
              bluetoothDeviceName: state.audioState?.bluetoothDeviceName ?? '',
            ),
            textAlign: TextAlign.center,
          ),
          active: !hasBluetooth && (currentRoute == AudioRoute.speaker),
          onPressed: enabled
              ? () {
                  if (state.audioState != null && hasBluetooth) {
                    _showAudioPopupMenu(context, state.audioState);
                  } else {
                    context.read<CallerCubit>().routeAudio(
                          currentRoute == AudioRoute.phone
                              ? AudioRoute.speaker
                              : AudioRoute.phone,
                        );
                  }
                }
              : null,
        );
      },
    );
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
    return CallProcessStateBuilder(
      builder: (context, state) {
        return Material(
          child: DialPad(
            controller: dialPadController,
            canDelete: false,
            bottomLeftButton: KeypadButton(
              borderOnIos: false,
              child: InkResponse(
                onTap: onCancelButtonPressed,
                child: Icon(
                  VialerSans.close,
                  color: context.brand.theme.colors.grey5,
                ),
              ),
            ),
            bottomCenterButton: CallButton.hangUp(
              onPressed:
                  state is! FinishedCalling ? onHangUpButtonPressed : null,
            ),
          ),
        );
      },
    );
  }
}

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phone_lib/flutter_phone_lib.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/presentation/resources/localizations.dart';
import 'package:vialer/presentation/resources/theme.dart';

import '../../../shared/widgets/caller.dart';
import '../../../shared/widgets/dial_pad/keypad.dart';
import '../../../shared/widgets/dial_pad/widget.dart';
import '../../../shared/widgets/nested_navigator.dart';
import 'audio_route_picker.dart';
import 'call_button.dart';
import 'call_process_state_builder.dart';

class CallActions extends StatefulWidget {
  const CallActions({
    required this.onTransferButtonPressed,
    this.navigatorKey,
    super.key,
  });

  /// Invoked when the transfer button is pressed. The call will always be
  /// put on hold.
  final VoidCallback onTransferButtonPressed;

  final GlobalKey<NavigatorState>? navigatorKey;

  @override
  State<CallActions> createState() => _CallActionsState();
}

class _CallActionsState extends State<CallActions> {
  static const _actionsRoute = 'actions';
  static const _dialPadRoute = 'dial-pad';

  final _dialPadController = TextEditingController();
  var _latestDialPadValue = '';

  void _hangUp() {
    unawaited(context.read<CallerCubit>().endVoipCall());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _dialPadController.addListener(() {
      final currentDialPadValue = _dialPadController.value.text;

      if (currentDialPadValue != _latestDialPadValue) {
        unawaited(
          context
              .read<CallerCubit>()
              .sendVoipDtmf(currentDialPadValue.characters.last),
        );
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
        },
      },
    );
  }
}

class _CallActionButtons extends StatelessWidget {
  const _CallActionButtons({
    required this.onHangUpButtonPressed,
    required this.onTransferButtonPressed,
  });

  final VoidCallback onHangUpButtonPressed;
  final VoidCallback onTransferButtonPressed;

  void _toggleMute(BuildContext context) =>
      unawaited(context.read<CallerCubit>().toggleMute());

  void _toggleDialPad(BuildContext context) {
    Future.delayed(const Duration(seconds: 1), () async {
      await SemanticsService.announce(
        context.msg.main.call.ongoing.actions.keypad.semanticPostPress,
        Directionality.of(context),
      );
    });

    unawaited(Navigator.pushNamed(context, 'dial-pad'));
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
      unawaited(context.read<CallerCubit>().mergeTransfer());

  void _toggleHold(BuildContext context) =>
      unawaited(context.read<CallerCubit>().toggleHoldVoipCall());

  void _hold(BuildContext context) =>
      unawaited(context.read<CallerCubit>().holdVoipCall());

  @override
  Widget build(BuildContext context) {
    return CallProcessStateBuilder(
      builder: (context, state) {
        final call = state.voipCall!;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: _ActionButton(
                      icon: const FaIcon(FontAwesomeIcons.microphoneSlash),
                      label: context.msg.main.call.ongoing.actions.mute,
                      includeActiveStatusInSemanticLabel: true,
                      onPressedTogglesActiveStatus: true,
                      active: state.isVoipCallMuted,
                      // We can't mute when on hold.
                      onPressed: !call.isOnHold && !state.isFinished
                          ? () => _toggleMute(context)
                          : null,
                    ),
                  ),
                  Expanded(
                    child: _ActionButton(
                      icon: const Icon(Icons.dialpad),
                      label: context.msg.main.call.ongoing.actions.keypad.label,
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
                          ? const FaIcon(FontAwesomeIcons.merge)
                          : const FaIcon(FontAwesomeIcons.arrowRightArrowLeft),
                      label: state.isInTransfer
                          ? context.msg.main.call.ongoing.actions.merge
                          : context
                              .msg.main.call.ongoing.actions.transfer.label,
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
                      icon: const FaIcon(FontAwesomeIcons.pause),
                      label: context.msg.main.call.ongoing.actions.hold,
                      includeActiveStatusInSemanticLabel: true,
                      onPressedTogglesActiveStatus: true,
                      active: call.isOnHold,
                      onPressed: state.isActionable
                          ? () => _toggleHold(context)
                          : null,
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
          ),
        );
      },
    );
  }
}

class _ActionButton extends StatefulWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    String? semanticLabel,
    this.active = false,
    this.includeActiveStatusInSemanticLabel = false,
    this.onPressedTogglesActiveStatus = false,
    this.onPressed,
  }) : semanticLabel = semanticLabel ?? label;
  final Widget icon;
  final String label;
  final String semanticLabel;
  final VoidCallback? onPressed;

  /// Whether to narrate the [active] status in the label when read by the
  /// screen reader.
  final bool includeActiveStatusInSemanticLabel;

  /// This indicates that the widget can assume that after [onPressed] is
  /// called, [active] is inversed. This property is necessary because [active]
  /// might be updated too late, and the screen reader will read out the out
  /// of date status on press.
  final bool onPressedTogglesActiveStatus;

  /// An active button is one that is currently in-use, so for example the
  /// hold button would be active if the call is current on-hold.
  final bool active;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  /// An enabled button is available to be pressed by the user, for example
  /// if the call is not yet connected, the user cannot transfer that call so
  /// the button will not be enabled.
  bool get _enabled => widget.onPressed != null;

  bool _active = false;

  String get _semanticLabel {
    final activeLabel =
        _active ? context.msg.generic.on : context.msg.generic.off;
    return '${widget.semanticLabel}. '
        '${widget.includeActiveStatusInSemanticLabel ? ' $activeLabel' : ''}';
  }

  @override
  void initState() {
    super.initState();

    _active = widget.active;
  }

  @override
  void didUpdateWidget(covariant _ActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.active != widget.active) {
      setState(() {
        _active = widget.active;
      });
    }
  }

  void _onPressed() {
    if (widget.onPressedTogglesActiveStatus) {
      setState(() {
        _active = !_active;
      });

      // On iOS, the state is already correctly announced after press.
      // On Android we have to do it manually.
      if (context.isAndroid) {
        unawaited(
          SemanticsService.announce(_semanticLabel, Directionality.of(context)),
        );
      }
    }

    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    const iconSize = 64.0;

    return Semantics(
      hint: _semanticLabel,
      button: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: iconSize,
            width: iconSize,
            child: Material(
              shape: const CircleBorder(),
              color: _active
                  ? context.brand.theme.colors.primary
                  : context.brand.theme.colors.primary.withOpacity(0),
              child: InkResponse(
                onTap: _enabled ? _onPressed : null,
                containedInkWell: _active,
                radius: _active ? iconSize : iconSize / 2,
                customBorder: const CircleBorder(),
                child: IconTheme.merge(
                  data: IconThemeData(
                    size: 32,
                    color: _pickIconColor(context),
                  ),
                  child: Center(
                    child: widget.icon,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ExcludeSemantics(
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 16,
                color: _pickTextColor(context),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Color _pickTextColor(BuildContext context) => _enabled
      ? context.brand.theme.colors.grey6
      : context.brand.theme.colors.grey2;

  Color _pickIconColor(BuildContext context) {
    if (_active) return context.brand.theme.colors.onPrimary;

    if (!_enabled) return context.brand.theme.colors.grey2;

    return context.brand.theme.colors.grey6;
  }
}

class _AudioRouteButton extends StatelessWidget {
  const _AudioRouteButton({
    this.enabled = true,
  });

  final bool enabled;

  Future<void> _showAudioPopupMenu(
    BuildContext context,
    AudioState? audioState,
  ) async {
    final caller = context.read<CallerCubit>();

    if (Platform.isIOS) {
      await caller.launchIOSAudioRoutePicker();
      return;
    }

    unawaited(
      SemanticsService.announce(
        context.msg.main.call.ongoing.actions.audioRoute.semanticPostPress,
        Directionality.of(context),
      ),
    );

    final selectedRoute = await showDialog<dynamic>(
      context: context,
      builder: (context) {
        return AudioRoutePicker(
          audioState: audioState!,
        );
      },
    );

    if (selectedRoute is AudioRoute) {
      await caller.routeAudio(selectedRoute);
    } else if (selectedRoute is BluetoothAudioRoute) {
      await caller.routeAudioToBluetoothDevice(selectedRoute);
    }
  }

  IconData _iconFor({
    required BuildContext context,
    required bool hasBluetooth,
    required AudioRoute currentRoute,
  }) {
    if (!hasBluetooth || currentRoute == AudioRoute.speaker) {
      return FontAwesomeIcons.volume;
    }

    if (currentRoute == AudioRoute.bluetooth) {
      return FontAwesomeIcons.bluetooth;
    }

    return FontAwesomeIcons.phone;
  }

  String _labelFor({
    required BuildContext context,
    required bool hasBluetooth,
    required AudioRoute currentRoute,
    required String bluetoothDeviceName,
  }) {
    if (!hasBluetooth || currentRoute == AudioRoute.speaker) {
      return context.msg.main.call.ongoing.actions.audioRoute.speaker;
    }

    if (currentRoute == AudioRoute.bluetooth) {
      return bluetoothDeviceName.isNotEmpty
          ? bluetoothDeviceName
          : context.msg.main.call.ongoing.actions.audioRoute.bluetooth;
    }

    return context.msg.main.call.ongoing.actions.audioRoute.phone;
  }

  String _semanticLabelFor({
    required BuildContext context,
    required String label,
    required bool hasBluetooth,
  }) {
    if (!hasBluetooth) return label;

    return context.msg.main.call.ongoing.actions.audioRoute
        .semanticLabel(label);
  }

  @override
  Widget build(BuildContext context) {
    return CallProcessStateBuilder(
      builder: (context, state) {
        final currentRoute = state.audioState?.currentRoute ?? AudioRoute.phone;
        final hasBluetooth = state.audioState != null &&
            state.audioState!.availableRoutes.contains(AudioRoute.bluetooth);

        final label = _labelFor(
          context: context,
          hasBluetooth: hasBluetooth,
          currentRoute: currentRoute,
          bluetoothDeviceName: state.audioState?.bluetoothDeviceName ?? '',
        );

        return _ActionButton(
          icon: FaIcon(
            _iconFor(
              context: context,
              hasBluetooth: hasBluetooth,
              currentRoute: currentRoute,
            ),
          ),
          label: label,
          semanticLabel: _semanticLabelFor(
            context: context,
            label: label,
            hasBluetooth: hasBluetooth,
          ),
          includeActiveStatusInSemanticLabel: !hasBluetooth,
          onPressedTogglesActiveStatus: !hasBluetooth,
          active: !hasBluetooth && (currentRoute == AudioRoute.speaker),
          onPressed: enabled
              ? () {
                  if (state.audioState != null && hasBluetooth) {
                    unawaited(_showAudioPopupMenu(context, state.audioState));
                  } else {
                    unawaited(
                      context.read<CallerCubit>().routeAudio(
                            currentRoute == AudioRoute.phone
                                ? AudioRoute.speaker
                                : AudioRoute.phone,
                          ),
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
  const _DialPad({
    required this.dialPadController,
    required this.onHangUpButtonPressed,
    required this.onCancelButtonPressed,
  });

  final TextEditingController dialPadController;
  final VoidCallback onHangUpButtonPressed;
  final VoidCallback onCancelButtonPressed;

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
                child: Center(
                  child: FaIcon(
                    FontAwesomeIcons.xmark,
                    size: 32,
                    color: context.brand.theme.colors.grey5,
                  ),
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

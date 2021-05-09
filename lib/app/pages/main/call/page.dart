import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phone_lib/call/call.dart';
import 'package:flutter_phone_lib/call/call_state.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_phone_lib/audio/audio_route.dart';
import 'package:flutter_phone_lib/audio/audio_state.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vialer/app/pages/main/dialer/page.dart';
import 'package:vialer/app/pages/main/dialer/widgets/t9/widget.dart';

import '../../../resources/localizations.dart';
import '../../../resources/theme.dart';
import '../../../util/brand.dart';
import '../widgets/caller.dart';
import '../widgets/connectivity_alert.dart';
import '../widgets/dial_pad/keypad.dart';
import '../widgets/dial_pad/widget.dart';
import 'widgets/call_button.dart';

class CallPage extends StatefulWidget {
  const CallPage({
    Key? key,
  }) : super(key: key);

  @override
  _CallPageState createState() => _CallPageState();
}

// ignore: prefer_mixin
class _CallPageState extends State<CallPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // When the user dismisses the call screen, it will hide if
    // there is no call ongoing.
    if (state == AppLifecycleState.paused) {
      final call = context.read<CallerCubit>().processState.voipCall;

      if (call == null || call.state == CallState.ended) {
        _popCallScreen(context);
      }
    }
  }

  void _popAfter(Duration duration) {
    Timer(duration, () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  void _popCallScreen(BuildContext context) =>
      Navigator.popUntil(context, (route) => route.isFirst);

  // Only called when the state type has changed, not when a state with the same
  // type but different call information has been emitted.
  Future<void> _onStateChanged(BuildContext context, CallerState state) async {
    if (state is FinishedCalling) {
      if (state.voipCall != null && state.voipCall!.duration >= 1) {
        final duration =
            Duration(seconds: (state is AttendedTransferComplete) ? 3 : 0);

        Timer(duration, () {
          if (mounted) {
            _requestCallRating(context, state)
                .then((_) => _popCallScreen(context));
          }
        });
      } else {
        _popAfter(const Duration(seconds: 3));
      }
    }
  }

  Future<void> _requestCallRating(BuildContext context, FinishedCalling state) {
    Timer(const Duration(seconds: 10), () {
      if (mounted) {
        _popCallScreen(context);
      }
    });

    return showDialog<double>(
        context: context,
        builder: (context) {
          return BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 10,
              sigmaY: 10,
            ),
            child: AlertDialog(
              title: Text(
                context.msg.main.call.rate.title,
                textScaleFactor: 0.8,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    RatingBar(
                      initialRating: 0,
                      direction: Axis.horizontal,
                      allowHalfRating: false,
                      itemCount: 5,
                      tapOnlyMode: true,
                      ratingWidget: RatingWidget(
                        full: Icon(
                          VialerSans.star,
                          color: context.brand.theme.primary,
                        ),
                        half: const SizedBox(),
                        empty: Icon(
                          VialerSans.starOutline,
                          color: context.brand.theme.grey4,
                        ),
                      ),
                      itemPadding: const EdgeInsets.symmetric(
                        horizontal: 6.0,
                      ),
                      onRatingUpdate: (rating) =>
                          _submitCallRating(rating, state),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 10,
                        right: 10,
                        top: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.msg.main.call.rate.lowerLabel,
                            textScaleFactor: 0.9,
                          ),
                          Text(
                            context.msg.main.call.rate.upperLabel,
                            textScaleFactor: 0.9,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  void _submitCallRating(double rating, FinishedCalling state) {
    context.read<CallerCubit>().rateVoipCall(
          rating: rating.toInt(),
          call: state.voipCall!,
        );

    Timer(const Duration(seconds: 1), () {
      _popCallScreen(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConnectivityAlert(
        child: BlocConsumer<CallerCubit, CallerState>(
          listenWhen: (previous, current) =>
              previous.runtimeType != current.runtimeType,
          listener: _onStateChanged,
          builder: (context, state) {
            // We can make this assertion, because if we're not in
            // the process of a call (state is CallProcessState),
            // this page wouldn't show anyway.
            final processState = state as CallProcessState;
            final call = processState.voipCall!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (state is AttendedTransfer ||
                    state is AttendedTransferComplete)
                  _CallTransferBar(inactiveCall: state.voip!.inactiveCall!),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        context.brand.theme.callGradientStart,
                        context.brand.theme.callGradientEnd,
                      ],
                    ),
                  ),
                  child: DefaultTextStyle.merge(
                    style: TextStyle(
                      color: context.brand.theme.onCallGradientColor,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 48),
                        Text(
                          call.remotePartyHeading,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        Text(
                          call.remotePartySubheading,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(13.5),
                            color: context.brand.theme.callGradientStart,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: Text(
                            processState is InitiatingCall
                                ? context.msg.main.call.state.calling
                                : processState is FinishedCalling
                                    ? context.msg.main.call.state.callEnded
                                    : call.prettyDuration,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                if (state is AttendedTransferComplete)
                  _InformationBox(
                    icon: VialerSans.check,
                    text: context.msg.main.call.state.transferComplete,
                  ),
                const Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: _CallActions(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }
}

class _InformationBox extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InformationBox({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
            padding: const EdgeInsets.only(top: 30, bottom: 20),
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13.5),
                  color: context.brand.theme.callGradientStart,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: DefaultTextStyle.merge(
                    child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: context.brand.theme.onCallGradientColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      WidgetSpan(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4.0, right: 8.0),
                          child: Icon(
                            icon,
                            color: context.brand.theme.onCallGradientColor,
                            size: 22,
                          ),
                        ),
                      ),
                      TextSpan(text: text),
                    ],
                  ),
                ),
                ),
            ),
        ),
      ],
    );
  }
}

class _CallTransferBar extends StatelessWidget {
  final Call? inactiveCall;
  final Widget? text;

  const _CallTransferBar({this.inactiveCall, this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: const Border(
          bottom: BorderSide(
            width: 2.0,
            color: Colors.white,
          ),
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            context.brand.theme.callGradientStart,
            context.brand.theme.callGradientEnd,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 30, bottom: 15),
        child: DefaultTextStyle.merge(
          style: TextStyle(
            color: context.brand.theme.onCallGradientColor,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Wrap(
                spacing: 5,
                children: [
                  if (text != null)
                    text!,
                  if (inactiveCall != null)
                    _buildInactiveCallText(context, inactiveCall!),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInactiveCallText(BuildContext context, Call inactiveCall) =>
      RichText(
        text: TextSpan(
          children: [
            TextSpan(
                text: '${inactiveCall.remotePartyHeading}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: '- ${inactiveCall.prettyDuration} - '),
            TextSpan(
                text: inactiveCall.isOnHold
                    ? context.msg.main.call.state.callOnHold
                    : context.msg.main.call.state.callEnded),
          ],
        ),
      );
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
        ? active
            ? context.brand.theme.onPrimaryColor
            : context.brand.theme.grey6
        : context.brand.theme.grey4;

    const size = 96.0;

    return SizedBox(
      width: size,
      height: size,
      child: Material(
        shape: const CircleBorder(),
        color: active
            ? context.brand.theme.primary
            : context.brand.theme.primary.withOpacity(0),
        child: InkResponse(
          onTap: onPressed,
          containedInkWell: active,
          radius: active ? size : size / 2,
          customBorder: const CircleBorder(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconTheme.merge(
                data: IconThemeData(
                  size: 32,
                  color: color,
                ),
                child: icon,
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
          ),
        ),
      ),
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

    var selectedRoute = await showDialog<AudioRoute>(
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
                      formatBluetoothLabel(
                        context: context,
                        bluetoothDeviceName: bluetoothDeviceName,
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

  Text formatBluetoothLabel({
    required BuildContext context,
    required String bluetoothDeviceName,
  }) {
    final label = context.msg.main.call.actions.bluetooth;

    return Text(
      toBeginningOfSentenceCase(
        bluetoothDeviceName.isNotEmpty
            ? '$label ($bluetoothDeviceName)'
            : label,
      )!,
    );
  }

  Icon findIcon({
    required BuildContext context,
    required bool hasBluetooth,
    required AudioRoute currentRoute,
  }) {
    if (!hasBluetooth || currentRoute == AudioRoute.speaker) {
      return const Icon(VialerSans.speaker);
    }

    if (currentRoute == AudioRoute.bluetooth) {
      return const Icon(VialerSans.bluetooth);
    }

    return const Icon(VialerSans.phone);
  }

  Text findText({
    required BuildContext context,
    required bool hasBluetooth,
    required AudioRoute currentRoute,
    required String bluetoothDeviceName,
  }) {
    if (!hasBluetooth || currentRoute == AudioRoute.speaker) {
      return Text(context.msg.main.call.actions.speaker);
    }

    if (currentRoute == AudioRoute.bluetooth) {
      return bluetoothDeviceName.isNotEmpty
          ? Text(bluetoothDeviceName)
          : Text(context.msg.main.call.actions.bluetooth);
    }

    return Text(context.msg.main.call.actions.phone);
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
        icon: findIcon(
          context: context,
          hasBluetooth: hasBluetooth,
          currentRoute: currentRoute,
        ),
        text: findText(
          context: context,
          hasBluetooth: hasBluetooth,
          currentRoute: currentRoute,
          bluetoothDeviceName:
              processState.audioState?.bluetoothDeviceName ?? '',
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

class _CallActions extends StatefulWidget {
  const _CallActions({
    Key? key,
  }) : super(key: key);

  @override
  _CallActionsState createState() => _CallActionsState();
}

class _CallActionsState extends State<_CallActions> {
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

  void _transfer(BuildContext context) {
    Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
      builder: (context) =>
          BlocBuilder<CallerCubit, CallerState>(builder: (context, state) {
        final processState = state as CallProcessState;

        return DialerPage(
          isInBottomNavBar: false,
          callButton: CallButton.transfer(
              onCall: (number) {
                context.read<CallerCubit>().beginTransfer(number);
                Navigator.of(context).pop();
              }
          ),
          header: _CallTransferBar(
            text: RichText(
              text: TextSpan(children: [
                const TextSpan(text: 'Transferring '),
                TextSpan(
                  text: '${processState.voip!.activeCall!.remotePartyHeading}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: ' to'),
              ]),
            ),
          ),
        );
      }),
    ));
  }

  void _merge(BuildContext context) =>
      context.read<CallerCubit>().mergeTransfer();

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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                _ActionButton(
                  icon: const Icon(VialerSans.mute),
                  text: Text(context.msg.main.call.actions.mute),
                  active: processState.isVoipCallMuted,
                  // We can't mute when on hold.
                  onPressed: !call.isOnHold ? () => _toggleMute(context) : null,
                ),
                const Spacer(),
                _ActionButton(
                  icon: const Icon(VialerSans.dialpad),
                  text: Text(context.msg.main.call.actions.keypad),
                  onPressed: () => _toggleDialPad(context),
                ),
                const Spacer(),
                const _AudioRouteButton(),
                const Spacer(flex: 2),
              ],
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),
                _ActionButton(
                  icon: processState.isInTransfer
                      ? const Icon(VialerSans.merge)
                      : const Icon(VialerSans.transfer),
                  text: Text(context.msg.main.call.actions.transfer),
                  onPressed: () => processState.isInTransfer
                      ? _merge(context)
                      : _transfer(context),
                ),
                const Spacer(),
                _ActionButton(
                  icon: const Icon(VialerSans.onHold),
                  text: Text(context.msg.main.call.actions.hold),
                  active: call.isOnHold,
                  onPressed: () => _toggleHold(context),
                ),
                const Spacer(flex: 3),
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

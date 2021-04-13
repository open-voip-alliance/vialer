import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

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
    Key key,
  }) : super(key: key);

  @override
  _CallPageState createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  void _popAfter(Duration duration) {
    Timer(duration, () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  // Only called when the state type has changed, not when a state with the same
  // type but different call information has been emitted.
  void _onStateChanged(BuildContext context, CallerState state) {
    if (state is FinishedCalling) {
      _popAfter(const Duration(seconds: 3));
    }
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
            final call = processState.voipCall;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: _CallActions(
                      popAfter: _popAfter,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final Widget icon;
  final Widget text;

  final bool active;

  final VoidCallback onPressed;

  const _ActionButton({
    Key key,
    @required this.icon,
    @required this.text,
    this.active = false,
    @required this.onPressed,
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

class _CallActions extends StatefulWidget {
  final void Function(Duration) popAfter;

  const _CallActions({
    Key key,
    @required this.popAfter,
  }) : super(key: key);

  @override
  _CallActionsState createState() => _CallActionsState();
}

class _CallActionsState extends State<_CallActions> {
  static const _actionsRoute = 'actions';
  static const _dialPadRouteName = 'dial-pad';

  final _navigatorKey = GlobalKey<NavigatorState>();
  final _dialPadController = TextEditingController();

  String _latestDialPadValue;

  void _hangUp() {
    context.read<CallerCubit>().endVoipCall();
    widget.popAfter(const Duration(seconds: 1));
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
    if (_navigatorKey.currentState.canPop()) {
      _navigatorKey.currentState.pop();
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
                  onCancelButtonPressed: _navigatorKey.currentState.pop,
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
    Key key,
    @required this.onHangUpButtonPressed,
  }) : super(key: key);

  void _toggleMute(BuildContext context) =>
      context.read<CallerCubit>().toggleMute();

  void _toggleDialPad(BuildContext context) {
    Navigator.pushNamed(context, 'dial-pad');
  }

  void _toggleSpeaker() {}

  void _transfer() {}

  void _toggleHold(BuildContext context) =>
      context.read<CallerCubit>().toggleHoldVoipCall();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CallerCubit, CallerState>(
      builder: (context, state) {
        final processState = state as CallProcessState;

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
                  onPressed: !processState.voipCall.isOnHold
                      ? () => _toggleMute(context)
                      : null,
                ),
                const Spacer(),
                _ActionButton(
                  icon: const Icon(VialerSans.dialpad),
                  text: Text(context.msg.main.call.actions.keypad),
                  onPressed: () => _toggleDialPad(context),
                ),
                const Spacer(),
                _ActionButton(
                  icon: const Icon(VialerSans.speaker),
                  text: Text(context.msg.main.call.actions.speaker),
                  onPressed: _toggleSpeaker,
                ),
                const Spacer(flex: 2),
              ],
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),
                _ActionButton(
                  icon: const Icon(VialerSans.transfer),
                  text: Text(context.msg.main.call.actions.transfer),
                  onPressed: _transfer,
                ),
                const Spacer(),
                _ActionButton(
                  icon: const Icon(VialerSans.onHold),
                  text: Text(context.msg.main.call.actions.hold),
                  active: processState.voipCall.isOnHold,
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
    Key key,
    @required this.dialPadController,
    @required this.onHangUpButtonPressed,
    @required this.onCancelButtonPressed,
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

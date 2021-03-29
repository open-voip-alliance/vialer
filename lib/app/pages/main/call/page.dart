import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../../resources/localizations.dart';
import '../../../resources/theme.dart';
import '../../../util/brand.dart';
import '../widgets/caller.dart';
import '../widgets/connectivity_alert.dart';
import 'widgets/call_button.dart';

class CallPage extends StatefulWidget {
  const CallPage({
    Key key,
  }) : super(key: key);

  @override
  _CallPageState createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  void _toggleMute() {}

  void _toggleKeypad() {}

  void _toggleSpeaker() {}

  void _transfer() {}

  void _toggleOnHold() {}

  void _hangUp() {
    context.read<CallerCubit>().endCall();

    _popAfter(const Duration(seconds: 1));
  }

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
            final call = processState.call;

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
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
                    _ActionButton(
                      icon: const Icon(VialerSans.mute),
                      text: Text(context.msg.main.call.actions.mute),
                      onPressed: _toggleMute,
                    ),
                    const Spacer(),
                    _ActionButton(
                      icon: const Icon(VialerSans.dialpad),
                      text: Text(context.msg.main.call.actions.keypad),
                      onPressed: _toggleKeypad,
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
                      onPressed: _toggleOnHold,
                    ),
                    const Spacer(flex: 3),
                  ],
                ),
                const SizedBox(height: 48),
                Center(
                  child: CallButton.hangUp(
                    onPressed: state is! FinishedCalling ? _hangUp : null,
                  ),
                ),
                const SizedBox(height: 32),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Meant to be used in a [Flex] widget (e.g. [Row] or [Column]).
class _ActionButton extends StatelessWidget {
  final Widget icon;
  final Widget text;

  final VoidCallback onPressed;

  const _ActionButton({
    Key key,
    @required this.icon,
    @required this.text,
    @required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final color =
        enabled ? context.brand.theme.grey6 : context.brand.theme.grey4;

    return Expanded(
      flex: 2,
      child: InkResponse(
        onTap: onPressed,
        radius: 48,
        child: Column(
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
    );
  }
}

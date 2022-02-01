import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phone_lib/flutter_phone_lib.dart'
    hide AttendedTransferStarted;

import '../../../../domain/entities/call_problem.dart';
import '../../../resources/localizations.dart';
import '../../../resources/theme.dart';
import '../../../util/widgets_binding_observer_registrar.dart';
import '../widgets/caller.dart';
import '../widgets/connectivity_alert.dart';
import 'call_feedback/call_feedback.dart';
import 'widgets/call_actions.dart';
import 'widgets/call_process_state_builder.dart';
import 'widgets/call_transfer_bar.dart';

class CallPage extends StatefulWidget {
  const CallPage({
    Key? key,
  }) : super(key: key);

  @override
  _CallPageState createState() => _CallPageState();
}

class _CallPageState extends State<CallPage>
    with WidgetsBindingObserver, WidgetsBindingObserverRegistrar {
  // We sometimes want to dismiss the screen after an amount of seconds
  // we will store this timer so we can cancel it if another call is started.
  Timer? _dismissScreenTimer;

  /// We will only ask for a call rating on this percentage of calls.
  static const _percentageChanceOfAskingForCallRating = 15;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // When the user dismisses the call screen, it will hide if
    // there is no call ongoing.
    if (state == AppLifecycleState.paused) {
      final call = context.read<CallerCubit>().processState.voipCall;

      if (call == null || call.state == CallState.ended) {
        _dismissCallPage(context);
      }
    }
  }

  /// Dismisses the call screen, including any windows or dialogs
  /// display over, taking the user all the way back to the
  /// previous screen.
  ///
  /// Optionally provide a [after] duration for this to be
  /// performed after a delay.
  void _dismissCallPage(BuildContext context, {Duration? after}) {
    dismiss() {
      if (mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    }

    if (after == null) {
      dismiss();
      return;
    }

    _dismissScreenTimer = Timer(after, dismiss);
  }

  // Only called when the state type has changed, not when a state with the same
  // type but different call information has been emitted.
  Future<void> _onStateChanged(BuildContext context, CallerState state) async {
    if (state is CanCall) {
      final shouldAskForCallRating =
          Random().nextInt(100) < _percentageChanceOfAskingForCallRating;

      if (state is FinishedCalling &&
          state.voipCall != null &&
          state.voipCall!.duration >= 1 &&
          shouldAskForCallRating) {
        Timer(const Duration(seconds: 1), () {
          if (mounted) {
            _requestCallRating(context, state)
                .then((_) => _dismissCallPage(context));
          }
        });
      } else {
        _dismissCallPage(context, after: const Duration(seconds: 2));
      }
    } else {
      // If we get a non-finished state we want to make sure to cancel our
      // dismiss timer so we don't hide the screen with an active call. This
      // might occur if a new call is started quickly after the last one.
      _dismissScreenTimer?.cancel();
    }
  }

  Future<void> _requestCallRating(BuildContext context, FinishedCalling state) {
    return showDialog<double>(
      context: context,
      builder: (context) => CallFeedback(
        onFeedbackReady: (result) => _submitCallRating(
          result,
          state,
        ),
        onUserFinishedFeedbackProcess: () => _dismissCallPage(
          context,
          after: const Duration(milliseconds: 500),
        ),
      ),
    );
  }

  void _submitCallRating(
    CallFeedbackResult result,
    FinishedCalling state,
  ) =>
      context.read<CallerCubit>().rateVoipCall(
            result: result,
            call: state.voipCall!,
          );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConnectivityAlert(
        child: BlocListener<CallerCubit, CallerState>(
          listenWhen: (previous, current) =>
              previous.runtimeType != current.runtimeType,
          listener: _onStateChanged,
          child: CallProcessStateBuilder(
            builder: (context, state) {
              final call = state.voipCall!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: context.brand.theme.primaryGradient,
                    ),
                    child: SafeArea(
                      child: Column(
                        children: [
                          if ((state is AttendedTransferStarted ||
                                  state is AttendedTransferComplete) &&
                              state.voip!.inactiveCall != null)
                            CallTransferInProgressBar(
                              inactiveCall: state.voip!.inactiveCall!,
                            ),
                          DefaultTextStyle.merge(
                            style: TextStyle(
                              color:
                                  context.brand.theme.colors.onPrimaryGradient,
                            ),
                            child: Column(
                              children: [
                                const SizedBox(height: 12),
                                Text(
                                  call.remotePartyHeading,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  call.remotePartySubheading,
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(13.5),
                                    color: context.brand.theme.colors
                                        .primaryGradientStart,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 4,
                                  ),
                                  child: Text(
                                    state is InitiatingCall
                                        ? context
                                            .msg.main.call.ongoing.state.calling
                                        : state is FinishedCalling
                                            ? context.msg.main.call.ongoing
                                                .state.callEnded
                                            : call.prettyDuration,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (context.isAndroid)
                                  const SizedBox(height: 12),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: CallActions(),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

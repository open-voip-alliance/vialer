import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phone_lib/call/call_state.dart';
import 'package:provider/provider.dart';

import '../../../resources/localizations.dart';
import '../../../util/brand.dart';
import '../../../util/widgets_binding_observer_registrar.dart';
import '../widgets/caller.dart';
import '../widgets/connectivity_alert.dart';
import 'widgets/call_actions.dart';
import 'widgets/call_rating.dart';
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
      Navigator.popUntil(context, (route) => route.isFirst);
    }

    if (after == null) {
      dismiss();
      return;
    }

    Timer(after, () {
      if (mounted) dismiss();
    });
  }

  // Only called when the state type has changed, not when a state with the same
  // type but different call information has been emitted.
  Future<void> _onStateChanged(BuildContext context, CallerState state) async {
    if (state is FinishedCalling) {
      if (state.voipCall != null && state.voipCall!.duration >= 1) {
        Timer(const Duration(seconds: 1), () {
          if (mounted) {
            _requestCallRating(context, state)
                .then((_) => _dismissCallPage(context));
          }
        });
      } else {
        _dismissCallPage(context, after: const Duration(seconds: 3));
      }
    }
  }

  Future<void> _requestCallRating(BuildContext context, FinishedCalling state) {
    _dismissCallPage(context, after: const Duration(seconds: 10));

    return showDialog<double>(
      context: context,
      builder: (context) => CallRating(
        onCallRated: (rating) => _submitCallRating(rating, state),
      ),
    );
  }

  void _submitCallRating(double rating, FinishedCalling state) {
    context.read<CallerCubit>().rateVoipCall(
          rating: rating.toInt(),
          call: state.voipCall!,
        );

    _dismissCallPage(context, after: const Duration(seconds: 1));
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
                if (state is AttendedTransferStarted ||
                    state is AttendedTransferComplete)
                  CallTransferInProgressBar(
                    inactiveCall: state.voip!.inactiveCall!,
                  ),
                Container(
                  decoration: BoxDecoration(
                    gradient: context.brand.theme.primaryGradient,
                  ),
                  child: DefaultTextStyle.merge(
                    style: TextStyle(
                      color: context.brand.theme.onPrimaryGradientColor,
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
                            color:
                                context.brand.theme.primaryGradientStartColor,
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
    );
  }
}

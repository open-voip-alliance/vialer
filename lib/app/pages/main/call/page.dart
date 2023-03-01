import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phone_lib/flutter_phone_lib.dart'
    hide AttendedTransferStarted;

import '../../../../domain/feedback/call_problem.dart';
import '../../../resources/localizations.dart';
import '../../../resources/theme.dart';
import '../../../util/widgets_binding_observer_registrar.dart';
import '../widgets/caller.dart';
import '../widgets/nested_navigator.dart';
import 'call_feedback/call_feedback.dart';
import 'widgets/call_actions.dart';
import 'widgets/call_header_container.dart';
import 'widgets/call_process_state_builder.dart';
import 'widgets/call_transfer.dart';
import 'widgets/call_transfer_bar.dart';

class CallPage extends StatefulWidget {
  const CallPage({
    Key? key,
  }) : super(key: key);

  @override
  _CallOrTransferPageState createState() => _CallOrTransferPageState();
}

const _callRoute = 'call';
const _transferRoute = 'transfer';
const _contactsRoute = 'contacts';

class _CallOrTransferPageState extends State<CallPage> {
  @override
  Widget build(BuildContext context) {
    return NestedNavigator(
      // Users can never leave the ongoing call page.
      onWillPop: () => SynchronousFuture(false),
      fullscreenDialog: true,
      routes: {
        _callRoute: (context, _) => const _CallPage(),
        _transferRoute: (context, _) {
          return Scaffold(
            body: Container(
              alignment: Alignment.center,
              child: CallProcessStateBuilder(
                builder: (context, state) {
                  return CallTransfer(
                    activeCall: state.voipCall!,
                    onTransferTargetSelected: (number) {
                      context.read<CallerCubit>().beginTransfer(number);
                      Navigator.of(context).pop();
                    },
                    onCloseButtonPressed: () =>
                        Navigator.of(context, rootNavigator: true).pop(),
                    onContactsButtonPressed: () {
                      Navigator.pushNamed(context, _contactsRoute).then(
                        (number) => context
                            .read<CallerCubit>()
                            .beginTransfer(number as String),
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
      },
    );
  }
}

/// The actual call page.
class _CallPage extends StatefulWidget {
  const _CallPage({
    Key? key,
  }) : super(key: key);

  @override
  _CallPageState createState() => _CallPageState();
}

class _CallPageState extends State<_CallPage>
    with WidgetsBindingObserver, WidgetsBindingObserverRegistrar {
  // We sometimes want to dismiss the screen after an amount of seconds
  // we will store this timer so we can cancel it if another call is started.
  Timer? _dismissScreenTimer;

  @override
  void initState() {
    super.initState();

    // The call screen would show and persist if the phone was locked and
    // the app opened afterwards when the call already ended.
    if (!_isInCall(context)) {
      _dismissCallPage(context, after: const Duration(milliseconds: 500));
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // When the user dismisses the call screen, it will hide if
    // there is no call ongoing.
    if (state == AppLifecycleState.paused && !_isInCall(context)) {
      _dismissCallPage(context);
    }
  }

  bool _isInCall(BuildContext context) {
    final call = context.read<CallerCubit>().processState.voipCall;

    return !(call == null || call.state == CallState.ended);
  }

  /// Dismisses the call screen, including any windows or dialogs
  /// display over, taking the user all the way back to the
  /// previous screen.
  ///
  /// Optionally provide an [after] duration for this to be
  /// performed after a delay.
  void _dismissCallPage(BuildContext context, {Duration? after}) {
    dismiss() {
      if (mounted) {
        Navigator.of(context, rootNavigator: true)
            .popUntil((route) => route.isFirst);
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
    final cubit = context.read<CallerCubit>();

    if (state is CanCall) {
      if (state is FinishedCalling &&
          state.voipCall != null &&
          state.voipCall!.duration >= 1 &&
          cubit.shouldRequestCallRating()) {
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

  void _transfer() {
    final callerName = context
            .read<CallerCubit>()
            .processState
            .voip
            ?.activeCall
            ?.remotePartyHeading ??
        '';

    // TODO: Use correct phone number pronunciation.
    Future.delayed(const Duration(seconds: 1), () {
      SemanticsService.announce(
        context.msg.main.call.ongoing.actions.transfer
            .semanticPostPress(callerName),
        Directionality.of(context),
      );
    });

    // We want to use the closest navigator here, not the root navigator.
    Navigator.pushNamed(context, _transferRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<CallerCubit, CallerState>(
        listenWhen: (previous, current) =>
            previous.runtimeType != current.runtimeType,
        listener: _onStateChanged,
        child: CallProcessStateBuilder(
          builder: (context, state) {
            final call = state.voipCall!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CallHeaderContainer(
                  child: SafeArea(
                    child: Column(
                      children: [
                        if ((state is AttendedTransferStarted ||
                                state is AttendedTransferComplete) &&
                            state.voip!.inactiveCall != null)
                          CallTransferInProgressBar(
                            inactiveCall: state.voip!.inactiveCall!,
                          ),
                        _CallHeader(
                          call: call,
                          state: state,
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: CallActions(
                      onTransferButtonPressed: _transfer,
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

class _CallHeader extends StatelessWidget {
  final Call call;
  final CallerState state;

  const _CallHeader({
    required this.call,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      style: TextStyle(
        color: context.brand.theme.colors.onPrimaryGradient,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Text(
              call.remotePartyHeading,
              textAlign: TextAlign.center,
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
                color: context.brand.theme.colors.primaryGradientStart,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              child: Text(
                state is StartingCall
                    ? context.msg.main.call.ongoing.state.calling
                    : state is FinishedCalling
                        ? context.msg.main.call.ongoing.state.callEnded
                        : call.prettyDuration,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

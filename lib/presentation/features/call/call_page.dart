import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phone_lib/flutter_phone_lib.dart'
    hide AttendedTransferStarted;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:vialer/presentation/resources/localizations.dart';
import 'package:vialer/presentation/resources/theme.dart';
import 'package:vialer/presentation/shared/widgets/animated_visibility.dart';

import '../../../../../data/repositories/metrics/metrics.dart';
import '../../../../data/models/feedback/call_problem.dart';
import '../../../../dependency_locator.dart';
import '../../shared/widgets/caller.dart';
import '../../shared/widgets/nested_navigator.dart';
import '../../util/stylized_snack_bar.dart';
import '../../util/widgets_binding_observer_registrar.dart';
import '../colltacts/controllers/colleagues/cubit.dart';
import '../colltacts/controllers/contacts/cubit.dart';
import '../colltacts/controllers/cubit.dart';
import '../colltacts/controllers/shared_contacts/cubit.dart';
import 'widgets/call_actions.dart';
import 'widgets/call_feedback/call_feedback.dart';
import 'widgets/call_header_container.dart';
import 'widgets/call_process_state_builder.dart';
import 'widgets/call_transfer.dart';
import 'widgets/call_transfer_bar.dart';

class CallPage extends StatefulWidget {
  const CallPage({
    super.key,
  });

  @override
  State<CallPage> createState() => _CallOrTransferPageState();
}

const _callRoute = 'call';
const _transferRoute = 'transfer';
const _contactsRoute = 'contacts';

class _CallOrTransferPageState extends State<CallPage> {
  @override
  Widget build(BuildContext context) {
    return _TemporaryCubitProvider(
      child: PopScope(
        canPop: false,
        child: NestedNavigator(
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
                          unawaited(
                            context.read<CallerCubit>().beginTransfer(number),
                          );
                          Navigator.of(context).pop();
                        },
                        onCloseButtonPressed: () =>
                            Navigator.of(context, rootNavigator: true).pop(),
                        onContactsButtonPressed: () {
                          unawaited(
                            Navigator.pushNamed(context, _contactsRoute).then(
                              (number) => context
                                  .read<CallerCubit>()
                                  .beginTransfer(number! as String),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              );
            },
          },
        ),
      ),
    );
  }
}

/// The actual call page.
class _CallPage extends StatefulWidget {
  const _CallPage();

  @override
  _CallPageState createState() => _CallPageState();
}

class _CallPageState extends State<_CallPage>
    with WidgetsBindingObserver, WidgetsBindingObserverRegistrar {
  // We sometimes want to dismiss the screen after an amount of seconds
  // we will store this timer so we can cancel it if another call is started.
  Timer? _dismissScreenTimer;
  Timer? _poorQualityCallTimer;

  /// The [Duration] that the call must be below the minimum quality threshold
  /// before we show a warning to the user.
  static const _poorQualityMinimumDuration =
      Duration(seconds: BAD_CALL_QUALITY_MIN_DURATION);

  bool isNotifyingUserAboutBadQualityCall = false;

  late final _metrics = dependencyLocator<MetricsRepository>();

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
    void dismiss() {
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

    final isInBadQualityCall = cubit.processState.isInBadQualityCall;

    if (!isInBadQualityCall || state is FinishedCalling) {
      _hideSnackBar(context);
    } else if (state is Calling && isInBadQualityCall) {
      _showSnackBarForLowMos(context);
      _metrics.track('ongoing-call-connectivity-warning-shown', {
        'call-id': state.voipCall?.callId,
        'mos': state.voipCall?.mos,
        'currentMos': state.voipCall?.currentMos,
      });
    }

    _announceStateChanged(context, state);
  }

  void _announceStateChanged(BuildContext context, CallerState state) {
    if (state is AttendedTransferComplete) {
      Future.delayed(const Duration(milliseconds: 500), () async {
        SemanticsService.announce(
          context.msg.main.call.transfer.complete.message,
          Directionality.of(context),
        );
      });
    } else if (state is Calling && state.isTransferAborted) {
      SemanticsService.announce(
        context.msg.main.call.transfer.abort.message,
        Directionality.of(context),
      );
    } else if (state is FinishedCalling) {
      SemanticsService.announce(
        context.msg.main.call.ended.message,
        Directionality.of(context),
      );
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
      unawaited(
        context.read<CallerCubit>().rateVoipCall(
              result: result,
              call: state.voipCall!,
            ),
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
    Future.delayed(const Duration(seconds: 1), () async {
      await SemanticsService.announce(
        context.msg.main.call.ongoing.actions.transfer
            .semanticPostPress(callerName),
        Directionality.of(context),
      );
    });

    // We want to use the closest navigator here, not the root navigator.
    unawaited(Navigator.pushNamed(context, _transferRoute));
  }

  void _showSnackBarForLowMos(BuildContext context) {
    if (_poorQualityCallTimer?.isActive == true) return;

    _poorQualityCallTimer = Timer(
      _poorQualityMinimumDuration,
      () {
        final state = context.read<CallerCubit>().state;
        final shouldNotifyUserAboutBadQualityCall =
            state is CallProcessState && state.isInBadQualityCall;

        setState(
          () => isNotifyingUserAboutBadQualityCall =
              shouldNotifyUserAboutBadQualityCall,
        );

        if (!shouldNotifyUserAboutBadQualityCall) return;

        showSnackBar(
          context,
          duration: const Duration(days: 365),
          icon: const FaIcon(FontAwesomeIcons.exclamation),
          label: Text(context.msg.main.call.ongoing.connectionWarning.title),
          padding: const EdgeInsets.only(right: 72),
          excludeSemantics: true,
        );
      },
    );
  }

  void _hideSnackBar(BuildContext context) {
    if (isNotifyingUserAboutBadQualityCall) {
      setState(() => isNotifyingUserAboutBadQualityCall = false);
    }
    _poorQualityCallTimer?.cancel();
    ScaffoldMessenger.of(context).clearSnackBars();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<CallerCubit, CallerState>(
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
                AnimatedVisibility(
                  visible: isNotifyingUserAboutBadQualityCall,
                  child: SizedBox(height: 100),
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
  const _CallHeader({
    required this.call,
    required this.state,
  });

  final Call call;
  final CallerState state;

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
            const Gap(12),
            Text(
              call.remotePartyHeading,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w300,
              ),
            ),
            const Gap(2),
            Text(
              call.remotePartySubheading,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const Gap(4),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13.5),
                color: context.brand.theme.colors.primaryGradientStart,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              child: _CallDuration(),
            ),
            const Gap(12),
          ],
        ),
      ),
    );
  }
}

class _CallDuration extends StatelessWidget {
  const _CallDuration();

  String _text(BuildContext context, CallProcessState state) {
    if (state is StartingCall) {
      return context.msg.main.call.ongoing.state.calling;
    }

    if (state is FinishedCalling) {
      return context.msg.main.call.ongoing.state.callEnded;
    }

    return state.voipCall?.prettyDuration ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return CallProcessStateBuilder(
      includeCallDurationChanges: true,
      builder: (context, state) {
        return Text(
          _text(context, state),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        );
      },
    );
  }
}

/// To resolve an issue causing users not to be able to transfer to contacts,
/// we are going to re-create the necessary cubits here. This is because
/// [ColltactsTabsCubit] and [ColleaguesCubit] were moved to be created
/// in `main/page.dart` rather than `global_bloc_provider.dart`. This page
/// is created independently of `main/page.dart` so does not receive the
/// necessary providers.
///
/// This should be removed when we have moved to Riverpod.
class _TemporaryCubitProvider extends StatelessWidget {
  const _TemporaryCubitProvider({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ColleaguesCubit>(
          create: (context) =>
              ColleaguesCubit(context.read<CallerCubit>())..refresh(),
        ),
        BlocProvider<ColltactsTabsCubit>(
          create: (context) => ColltactsTabsCubit(
            context.read<ContactsCubit>(),
            context.read<ColleaguesCubit>(),
            context.read<SharedContactsCubit>(),
          ),
        ),
      ],
      child: child,
    );
  }
}

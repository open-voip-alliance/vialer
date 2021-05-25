import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phone_lib/call/call_state.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

import '../../../resources/localizations.dart';
import '../../../resources/theme.dart';
import '../../../util/brand.dart';
import '../../../util/widgets_binding_observer_registrar.dart';
import '../widgets/caller.dart';
import '../widgets/connectivity_alert.dart';
import 'widgets/call_actions.dart';

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
        Navigator.of(context).pop();
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

  // Only called when the state type has changed, not when a state with the same
  // type but different call information has been emitted.
  Future<void> _onStateChanged(BuildContext context, CallerState state) async {
    if (state is FinishedCalling) {
      if (state.voipCall != null && state.voipCall!.duration >= 1) {
        _requestCallRating(context, state).then((_) => Navigator.pop(context));
      } else {
        _popAfter(const Duration(seconds: 3));
      }
    }
  }

  Future<void> _requestCallRating(BuildContext context, FinishedCalling state) {
    Timer(const Duration(seconds: 10), () {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
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
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(rating);
      }
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
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: CallActions(
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

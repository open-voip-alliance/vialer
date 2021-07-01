import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../domain/entities/exceptions/call_through.dart';
import '../../../../../domain/entities/survey/survey_trigger.dart';
import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';
import '../../../../routes.dart';
import '../../../../util/widgets_binding_observer_registrar.dart';
import '../../call/incoming/page.dart';
import '../../call/page.dart';
import '../../survey/dialog.dart';
import 'confirm/page.dart';
import 'cubit.dart';

class Caller extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  Caller._(this.navigatorKey, this.child);

  static Widget create({
    required GlobalKey<NavigatorState> navigatorKey,
    required Widget child,
  }) {
    return BlocProvider<CallerCubit>(
      create: (_) => CallerCubit(),
      child: Caller._(navigatorKey, child),
    );
  }

  @override
  _CallerState createState() => _CallerState();
}

class _CallerState extends State<Caller>
    with WidgetsBindingObserver, WidgetsBindingObserverRegistrar {
  bool _resumedOnceDuringCalling = false;

  NavigatorState get _navigatorState => widget.navigatorKey.currentState!;

  BuildContext get _navigatorContext => widget.navigatorKey.currentContext!;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cubit = context.read<CallerCubit>();

    if (state == AppLifecycleState.resumed) {
      if (cubit.state is Calling && !_resumedOnceDuringCalling) {
        // We keep track of this so we don't prematurely say we can call again,
        // because the app state will be resumed too soon.
        _resumedOnceDuringCalling = true;
        return;
      }

      cubit.notifyCanCall();
      _resumedOnceDuringCalling = false;
    }
  }

  static const _ringingRouteName = 'ringing';

  // NOTE: Only called when the state type changes, not when the same state
  // with a different `call` is emitted.
  Future<void> _onStateChanged(BuildContext context, CallerState state) async {
    if (state is Ringing) {
      await _navigatorState.push(
        MaterialPageRoute(
          settings: const RouteSettings(
            name: _ringingRouteName,
          ),
          builder: (_) => const IncomingCallPage(),
        ),
      );
    }

    if (state is InitiatingCall && state.isVoip ||
        (state is Calling &&
            state.isVoip &&
            state.voipCall!.direction.isInbound)) {
      await _navigatorState.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const CallPage(),
        ),
        // We want to go back to the main screen after a call
        // (not the dialer or possibly ringing screen).
        (route) => route.settings.name == Routes.main,
      );
    }

    if (state is ShowCallThroughConfirmPage) {
      await _navigatorState.push(
        ConfirmPageRoute(
          destination: state.destination,
          origin: state.origin,
        ),
      );
    }

    if (state is ShowCallThroughSurvey) {
      await SurveyDialog.show(
        // We use the context of the navigator key, because that key is
        // associated with the MaterialApp which has Localizations, which
        // the SurveyDialog needs.
        _navigatorContext,
        trigger: SurveyTrigger.afterThreeCallThroughCalls,
      );

      context.read<CallerCubit>().notifySurveyShown();
    }

    if (state is InitiatingCallFailed && !state.isVoip) {
      await _showCallThroughErrorDialog(
        _navigatorContext,
        state.exception as CallThroughException,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CallerCubit, CallerState>(
      listenWhen: (previous, current) =>
          previous.runtimeType != current.runtimeType,
      listener: _onStateChanged,
      child: widget.child,
    );
  }
}

Future<void> _showCallThroughErrorDialog(
  BuildContext context,
  CallThroughException exception,
) {
  String message, title = context.msg.main.callThrough.error.title;
  if (exception is InvalidDestinationException ||
      exception is NormalizationException) {
    message = context.msg.main.callThrough.error.invalidDestination;
  } else if (exception is NoMobileNumberException) {
    message = context.msg.main.callThrough.error.mobile.noMobileNumber;
    title = context.msg.main.callThrough.error.mobile.title;
  } else if (exception is NumberTooLongException) {
    message = context.msg.main.callThrough.error.numberTooLong.numberTooLong;
    title = context.msg.main.callThrough.error.numberTooLong.title;
  } else {
    message = context.msg.main.callThrough.error.unknown;
  }

  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      final content = SingleChildScrollView(
        child: Text(message),
      );

      final buttonText = context.msg.generic.button.ok;
      void buttonOnPressed() {
        Navigator.pop(context);
        // Also pop the confirm if it's there.
        Navigator.popUntil(context, (route) => route is! ConfirmPageRoute);
      }

      if (context.isIOS) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: content,
          actions: <Widget>[
            CupertinoButton(
              onPressed: buttonOnPressed,
              child: Text(buttonText),
            )
          ],
        );
      } else {
        return AlertDialog(
          title: Text(title),
          content: content,
          actions: <Widget>[
            TextButton(
              onPressed: buttonOnPressed,
              style: ButtonStyle(
                overlayColor: MaterialStateProperty.all(
                  Theme.of(context).primaryColorLight,
                ),
              ),
              child: Text(
                buttonText.toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        );
      }
    },
  );
}

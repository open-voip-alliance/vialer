import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../domain/entities/call_through_exception.dart';
import '../../../../../domain/entities/survey/survey_trigger.dart';

import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';

import '../../survey/dialog.dart';
import '../../dialer/confirm/page.dart';

import 'cubit.dart';

class Caller extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  Caller._(this.navigatorKey, this.child);

  static Widget create({
    @required GlobalKey<NavigatorState> navigatorKey,
    @required Widget child,
  }) {
    return BlocProvider<CallerCubit>(
      create: (_) => CallerCubit(),
      child: Caller._(navigatorKey, child),
    );
  }

  @override
  _CallerState createState() => _CallerState();
}

// ignore: prefer_mixin
class _CallerState extends State<Caller> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // A call can be made as soon as we're in the app again
    if (state == AppLifecycleState.resumed) {
      context.bloc<CallerCubit>().notifyCanCall();
    }
  }

  Future<void> _onStateChanged(BuildContext context, CallerState state) async {
    if (state is ShowConfirmPage) {
      await widget.navigatorKey.currentState.push(
        ConfirmPageRoute(destination: state.destination),
      );

      // Once popped off, we can call again
      context.bloc<CallerCubit>().notifyCanCall();
    }

    if (state is ShowCallThroughSurvey) {
      if (state.popPrevious) {
        widget.navigatorKey.currentState.pop();
      }

      await SurveyDialog.show(
        // We use the context of the navigator key, because that key is
        // associated with the MaterialApp which has Localizations, which
        // the SurveyDialog needs.
        widget.navigatorKey.currentContext,
        trigger: SurveyTrigger.afterThreeCallThroughCalls,
      );
    }

    if (state is InitiatingCallFailed) {
      await _showCallThroughErrorDialog(
        widget.navigatorKey.currentContext,
        state.exception,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CallerCubit, CallerState>(
      listener: _onStateChanged,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    super.dispose();

    WidgetsBinding.instance.removeObserver(this);
  }
}

Future<void> _showCallThroughErrorDialog(
  BuildContext context,
  CallThroughException exception,
) {
  String message;
  if (exception is InvalidDestinationException ||
      exception is NormalizationException) {
    message = context.msg.main.callThrough.error.invalidDestination;
  } else {
    message = context.msg.main.callThrough.error.unknown;
  }

  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      final title = Text(context.msg.main.callThrough.error.title);
      final content = SingleChildScrollView(
        child: Text(message),
      );

      final buttonText = context.msg.generic.button.ok;
      void buttonOnPressed() {
        Navigator.pop(context);
        // Also pop the confirm if it's there
        Navigator.popUntil(context, (route) => route is! ConfirmPageRoute);
      }

      if (context.isIOS) {
        return CupertinoAlertDialog(
          title: title,
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
          title: title,
          content: content,
          actions: <Widget>[
            FlatButton(
              onPressed: buttonOnPressed,
              child: Text(
                buttonText.toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              splashColor: Theme.of(context).primaryColorLight,
            ),
          ],
        );
      }
    },
  );
}

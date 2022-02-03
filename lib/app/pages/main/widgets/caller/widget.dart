import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../domain/entities/call_failure_reason.dart';
import '../../../../../domain/entities/exceptions/call_through.dart';
import '../../../../../domain/entities/survey/survey_trigger.dart';
import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';
import '../../../../routes.dart';
import '../../../../util/conditional_capitalization.dart';
import '../../../../util/pigeon.dart';
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
  bool _isRinging = false;

  NavigatorState get _navigatorState => widget.navigatorKey.currentState!;

  BuildContext get _navigatorContext => widget.navigatorKey.currentContext!;

  final CallScreenBehavior _callScreenBehavior = CallScreenBehavior();

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

  /// Launch the appropriate call screen depending on the platform,
  /// for iOS we will use the Flutter call screen and for Android we will
  /// use a native implementation.
  Future<void> launchIncomingCallScreen(Ringing state) async {
    final call = state.voipCall;

    if (call == null) return;

    if (context.isAndroid) {
      NativeIncomingCallScreen().launch(
        call.remotePartyHeading,
        call.remotePartySubheading,
        call.contact?.imageUri?.toString() ?? '',
      );
      return;
    }

    await _navigatorState.push(
      MaterialPageRoute(
        settings: const RouteSettings(
          name: _ringingRouteName,
        ),
        builder: (_) => const IncomingCallPage(),
      ),
    );
  }

  // NOTE: Only called when the state type changes, not when the same state
  // with a different `voipCall` is emitted.
  Future<void> _onStateChanged(BuildContext context, CallerState state) async {
    if (state is Ringing) {
      _isRinging = true;
      launchIncomingCallScreen(state);
    } else {
      // Last state was ringing, remove the incoming call page.
      if (_isRinging) {
        _navigatorState.popUntil(
          (route) => route.settings.name != _ringingRouteName,
        );
      }

      _isRinging = false;
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

    if (state is InitiatingCallFailed) {
      if (state is InitiatingCallFailedWithException) {
        if (state.isVoip) {
          await _showCallThroughErrorDialog(
            _navigatorContext,
            state.exception as CallThroughException,
          );
        } else {
          await _showInitiatingCallFailedDialogWithException(
            context,
            state.exception,
          );
        }
      } else if (state is InitiatingCallFailedWithReason) {
        await _showInitiatingCallFailedDialog(_navigatorContext, state.reason);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // We'll always update the call screen based on the state, even
        // if it hasn't changed to ensure the changes are applied.
        BlocListener<CallerCubit, CallerState>(
          listener: (context, state) => _callScreenBehavior.configure(
            showWhenLocked: state.isInCall,
          ),
        ),
        BlocListener<CallerCubit, CallerState>(
          listenWhen: (previous, current) =>
              previous.runtimeType != current.runtimeType,
          listener: _onStateChanged,
        ),
      ],
      child: widget.child,
    );
  }
}

Future<void> _showCallThroughErrorDialog(
  BuildContext context,
  CallThroughException exception,
) {
  String message, title = context.msg.main.call.error.title;
  if (exception is InvalidDestinationException ||
      exception is NormalizationException) {
    message = context.msg.main.call.error.callThrough.invalidDestination;
  } else if (exception is NoMobileNumberException) {
    message = context.msg.main.call.error.callThrough.mobile.noMobileNumber;
    title = context.msg.main.call.error.callThrough.mobile.title;
  } else if (exception is NumberTooLongException) {
    message =
        context.msg.main.call.error.callThrough.numberTooLong.numberTooLong;
    title = context.msg.main.call.error.callThrough.numberTooLong.title;
  } else {
    message = context.msg.main.call.error.unknown;
  }

  return _AlertDialog.show(
    context,
    title: Text(title),
    content: Text(message),
  );
}

Future<void> _showInitiatingCallFailedDialog(
  BuildContext context,
  CallFailureReason reason,
) {
  String message, title = context.msg.main.call.error.title;
  switch (reason) {
    case CallFailureReason.invalidCallState:
      message = context.msg.main.call.error.voip.invalidCallState;
      break;
    case CallFailureReason.noMicrophonePermission:
      message = context.msg.main.call.error.voip
          .noMicrophonePermission(context.brand.appName);
      break;
    case CallFailureReason.noConnectivity:
      message = context.msg.main.call.error.voip.noConnectivity;
      break;
    case CallFailureReason.inCall:
      message = context.msg.main.call.error.voip.inCall;
      break;
    case CallFailureReason.rejectedByAndroidTelecomFramework:
      message =
          context.msg.main.call.error.voip.rejectedByAndroidTelecomFramework;
      break;
    case CallFailureReason.unableToRegister:
      message = context.msg.main.call.error.voip.unableToRegister;
      break;
    case CallFailureReason.unknown:
      message = context.msg.main.call.error.unknown;
      break;
  }

  return _AlertDialog.show(
    context,
    title: Text(title),
    content: Text(message),
  );
}

Future<void> _showInitiatingCallFailedDialogWithException(
  BuildContext context,
  Exception exception,
) {
  return _AlertDialog.show(
    context,
    title: Text(context.msg.main.call.error.title),
    content: Text(context.msg.main.call.error.unknown),
  );
}

class _AlertDialog extends StatelessWidget {
  final Widget title;
  final Widget content;

  const _AlertDialog({
    Key? key,
    required this.title,
    required this.content,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context, {
    required Widget title,
    required Widget content,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return _AlertDialog(
          title: title,
          content: content,
        );
      },
    );
  }

  void _onOkButtonPressed(BuildContext context) {
    Navigator.pop(context);
    // Also pop the confirm page if it's there.
    Navigator.popUntil(context, (route) => route is! ConfirmPageRoute);
  }

  @override
  Widget build(BuildContext context) {
    final okText = Text(
      context.msg.generic.button.ok.toUpperCaseIfAndroid(context),
    );

    if (context.isIOS) {
      return CupertinoAlertDialog(
        title: title,
        content: SingleChildScrollView(
          child: content,
        ),
        actions: <Widget>[
          CupertinoButton(
            onPressed: () => _onOkButtonPressed(context),
            child: okText,
          )
        ],
      );
    } else {
      return AlertDialog(
        title: title,
        content: content,
        actions: <Widget>[
          TextButton(
            onPressed: () => _onOkButtonPressed(context),
            style: ButtonStyle(
              overlayColor: MaterialStateProperty.all(
                Theme.of(context).primaryColorLight,
              ),
            ),
            child: DefaultTextStyle.merge(
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
              child: okText,
            ),
          ),
        ],
      );
    }
  }
}

extension on CallScreenBehavior {
  // Pigeon doesn't support named parameters so using an extension method to
  // make this a little cleaner.
  void configure({required bool showWhenLocked}) =>
      showWhenLocked ? enable() : disable();
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../domain/entities/survey/survey_trigger.dart';

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

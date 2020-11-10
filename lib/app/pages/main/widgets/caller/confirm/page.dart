import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../../../../../domain/entities/brand.dart';

import '../../../../../resources/theme.dart';
import '../../../../../resources/localizations.dart';

import '../../../../../routes.dart';
import '../../../../../widgets/transparent_status_bar.dart';
import '../../../widgets/caller.dart';

import 'cubit.dart';

class ConfirmPage extends StatefulWidget {
  final String destination;
  final CallOrigin origin;

  ConfirmPage.__({@required this.destination, @required this.origin});

  static Widget _({
    @required String destination,
    @required CallOrigin origin,
  }) {
    return BlocProvider<ConfirmCubit>(
      create: (context) => ConfirmCubit(
        context.read<CallerCubit>(),
        destination,
      ),
      child: ConfirmPage.__(
        destination: destination,
        origin: origin,
      ),
    );
  }

  @override
  State<StatefulWidget> createState() => ConfirmPageState();
}

class ConfirmPageState extends State<ConfirmPage>
    with
        TickerProviderStateMixin,
        // ignore: prefer_mixin
        WidgetsBindingObserver {
  bool _madeCall = false;
  bool _canPop = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final cubit = context.read<ConfirmCubit>();

    if (Platform.isIOS && !_madeCall) {
      cubit.call(origin: widget.origin);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.inactive) {
      _madeCall = true;

      if (Platform.isIOS) {
        _canPop = false;
      }
    } else if (state == AppLifecycleState.resumed) {
      // We keep track on whether we can pop on iOS, because once the
      // calling app is opened the app is immediately in a resumed state, while
      // we only want to pop at the _second_, real resumed state.
      //
      // So, if before the timer finishes we are in an 'inactive' state again,
      // we won't pop, because that means the calling app is shown, most likely.
      //
      // We don't pop in the background like on Android, because on iOS it
      // saves the last visible frame of the app, showing it after the call has
      // ended for a split-second, before making the app active again, which is
      // quite jarring. Popping when the app is actually visible again prevents
      // this jarring effect, at the cost of 250ms of seeing the route
      // transition.
      if (Platform.isIOS) {
        _canPop = true;
      }

      // We use a timer so that if we do actually want to call, the app state
      // will be inactive a second time, and _canPop will be false when the
      // callback runs, and we won't pop yet.
      //
      // The duration of 200ms is not based on or in relation to anything,
      // except of the fact that it works.
      Timer(Duration(milliseconds: 200), () {
        // We need to make sure the state is mounted, because the timer can be
        // executed after the state has been disposed of.
        if (mounted &&
            _canPop &&
            context.read<CallerCubit>().state is! ShowCallThroughSurvey) {
          _pop();
        }
      });
    }
  }

  void _onCallerStateChanged(BuildContext context, CallerState state) {
    // Pop if we showed the call-through survey.
    if (state is ShowedCallThroughSurvey) {
      _pop();
    }
  }

  void _pop() {
    context.read<CallerCubit>().notifyCanCall();
    Navigator.popUntil(
      context,
      (route) => route.settings.name == Routes.main,
    );
  }

  void _onCancelButtonPressed(ConfirmCubit cubit) {
    _pop();
    cubit.notifyCanCall();
  }

  Future<bool> _onWillPop() async {
    _pop();

    // We pop ourselves
    return false;
  }

  static const _style = TextStyle(
    fontSize: 16,
  );

  static const _largeStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  @override
  Widget build(BuildContext context) {
    final appName = Provider.of<Brand>(context).appName;

    return BlocListener<CallerCubit, CallerState>(
      listener: _onCallerStateChanged,
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: TransparentStatusBar(
          brightness: Brightness.dark,
          child: Padding(
            padding: EdgeInsets.only(
              top: 64,
            ),
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              child: BlocBuilder<ConfirmCubit, ConfirmState>(
                builder: (context, state) {
                  final cubit = context.watch<ConfirmCubit>();

                  final paragraphDistance = 48 *
                      (1.0 - (MediaQuery.textScaleFactorOf(context) - 1.0));

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Column(
                      children: <Widget>[
                        Flexible(
                          // ScrollView is here in case even with the altered
                          // paragraph distance the text doesn't fit.
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                SizedBox(height: paragraphDistance),
                                Text(
                                  context.msg.main.dialer.confirm
                                      .title(appName),
                                  style: _largeStyle,
                                ),
                                SizedBox(height: paragraphDistance),
                                Text(
                                  context.msg.main.dialer.confirm.description
                                      .origin,
                                  style: _style,
                                ),
                                SizedBox(height: 8),
                                Text(state.outgoingCli, style: _largeStyle),
                                SizedBox(height: paragraphDistance),
                                Text(
                                  context.msg.main.dialer.confirm.description
                                      .main(
                                    appName,
                                  ),
                                  style: _style,
                                ),
                                SizedBox(height: paragraphDistance),
                                Text(
                                  context.msg.main.dialer.confirm.description
                                      .action,
                                  style: _style,
                                ),
                                SizedBox(height: 8),
                                Text(widget.destination, style: _largeStyle),
                              ],
                            ),
                          ),
                        ),
                        if (context.isAndroid)
                          _AndroidInputs(
                            checkboxValue: !state.showConfirmPage,
                            onCheckboxValueChangd: (v) =>
                                cubit.updateShowPopupSetting(!v),
                            onCallButtonPressed: () =>
                                cubit.call(origin: widget.origin),
                            onCancelButtonPressed: () =>
                                _onCancelButtonPressed(cubit),
                            destination: context.msg.main.dialer.confirm.button
                                .call(widget.destination)
                                .toUpperCase(),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();

    WidgetsBinding.instance.removeObserver(this);
  }
}

class _AndroidInputs extends StatelessWidget {
  final bool checkboxValue;
  final ValueChanged<bool> onCheckboxValueChangd;
  final VoidCallback onCallButtonPressed;
  final String destination;
  final VoidCallback onCancelButtonPressed;

  const _AndroidInputs({
    Key key,
    this.checkboxValue,
    this.onCheckboxValueChangd,
    this.onCallButtonPressed,
    this.destination,
    this.onCancelButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 40,
      ).copyWith(
        bottom: 16,
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  context.msg.main.dialer.confirm.description.showPopUpSetting,
                ),
                Checkbox(
                  value: checkboxValue,
                  activeColor: Theme.of(context).primaryColor,
                  onChanged: onCheckboxValueChangd,
                )
              ],
            ),
            SizedBox(
              width: double.infinity,
              child: RaisedButton(
                elevation: 4,
                onPressed: onCallButtonPressed,
                color: context.brandTheme.green2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      VialerSans.phone,
                      size: 16,
                      color: context.brandTheme.green3,
                    ),
                    SizedBox(width: 12),
                    Text(
                      destination,
                      style: TextStyle(
                        color: context.brandTheme.green3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FlatButton(
                onPressed: onCancelButtonPressed,
                child: Text(
                  context.msg.generic.button.cancel.toUpperCase(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConfirmPageRoute extends PageRoute {
  static const _curve = Curves.decelerate;
  static final _barrierColor = Colors.black.withOpacity(0.8);

  final String destination;
  final CallOrigin origin;

  ConfirmPageRoute({
    @required this.destination,
    @required this.origin,
  });

  @override
  bool get opaque => false;

  // We don't use this because the entry animation doesn't seem to work
  @override
  Color get barrierColor => null;

  @override
  String get barrierLabel => null;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return ConfirmPage._(destination: destination, origin: origin);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: _curve,
    );

    return DecoratedBoxTransition(
      decoration: curved.drive(
        DecorationTween(
          begin: BoxDecoration(
            color: _barrierColor.withOpacity(0.0),
          ),
          end: BoxDecoration(
            color: _barrierColor,
          ),
        ),
      ),
      child: SlideTransition(
        position: curved.drive(
          Tween<Offset>(
            begin: Offset(0, 0.25),
            end: Offset(0, 0),
          ),
        ),
        child: FadeTransition(
          opacity: curved,
          child: child,
        ),
      ),
    );
  }

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => Duration(milliseconds: 250);
}

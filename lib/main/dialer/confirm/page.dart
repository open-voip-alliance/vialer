import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vialer_lite/main/dialer/bloc.dart';
import 'package:vialer_lite/resources/theme.dart';

import '../../../widgets/transparent_status_bar.dart';

class ConfirmPage extends StatefulWidget {
  final DialerBloc bloc;
  final String phoneNumber;

  ConfirmPage(this.bloc, this.phoneNumber);

  @override
  State<StatefulWidget> createState() => _ConfirmPageState();
}

class _ConfirmPageState extends State<ConfirmPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  AnimationController _controller;
  Animation<double> _animation;

  void _call() {
    widget.bloc.add(Call(widget.phoneNumber, showedConfirmation: true));
  }

  void _pop() {
    _controller.reverse();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.decelerate,
    );

    _controller.addListener(() {
      if (_controller.isCompleted && Platform.isIOS && !_madeCall) {
        _call();
      } else if (_controller.isDismissed) {
        Navigator.of(context).pop();
      }
    });

    _controller.forward();
  }

  bool _showedDialog = false;
  bool _madeCall = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      if (Platform.isIOS && !_showedDialog) {
        _showedDialog = true;
      } else {
        _madeCall = true;
      }

      if (Platform.isIOS &&
          _madeCall &&
          _controller.status == AnimationStatus.reverse) {
        // Cancel the reverse animation when a call is going to be made
        _controller.value = 1.0;
      }
    }

    if (state == AppLifecycleState.resumed) {
      _controller.reverse();
    }
  }

  Future<bool> _onWillPop() async {
    _pop();
    // Return false because the popping will happen when the animation
    // is finished
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
    return WillPopScope(
      onWillPop: _onWillPop,
      child: TransparentStatusBar(
          brightness: Brightness.dark,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              AnimatedBuilder(
                animation: _animation,
                builder: (context, widget) {
                  final opacity = _animation.drive(
                    Tween<double>(
                      begin: 0,
                      end: 0.8,
                    ),
                  );

                  return Container(
                    color: Colors.black.withOpacity(opacity.value),
                  );
                },
              ),
              SlideTransition(
                position: _animation.drive(
                  Tween<Offset>(
                    begin: Offset(0, 0.25),
                    end: Offset(0, 0),
                  ),
                ),
                child: FadeTransition(
                  opacity: _animation,
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
                      child: Column(
                        children: <Widget>[
                          SizedBox(height: 48),
                          Text('Vialer Lite Call', style: _largeStyle),
                          SizedBox(height: 48),
                          Text('Dialing from your business number',
                              style: _style),
                          SizedBox(height: 8),
                          Text('(+31) 50 1234567', style: _largeStyle),
                          SizedBox(height: 48),
                          Text(
                            'Vialer Lite will route your call through,\n'
                            'keeping your personal number private',
                            style: _style,
                          ),
                          SizedBox(height: 48),
                          Text('Tap the “Call” button to dial:', style: _style),
                          SizedBox(height: 8),
                          Text(widget.phoneNumber, style: _largeStyle),
                          if (context.isAndroid)
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 40,
                                ).copyWith(
                                  bottom: 16,
                                ),
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      SizedBox(
                                        width: double.infinity,
                                        child: RaisedButton(
                                          elevation: 4,
                                          onPressed: _call,
                                          color: VialerColors.green2,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Icon(
                                                VialerSans.phone,
                                                size: 16,
                                                color: VialerColors.green3,
                                              ),
                                              SizedBox(width: 12),
                                              Text(
                                                'CALL ${widget.phoneNumber}',
                                                style: TextStyle(
                                                  color: VialerColors.green3,
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
                                          onPressed: () => _pop(),
                                          child: Text('CANCEL'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }
}

class ConfirmPageRoute extends PageRoute {
  final DialerBloc bloc;
  final String phoneNumber;

  ConfirmPageRoute({@required this.bloc, @required this.phoneNumber});

  @override
  bool get opaque => false;

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
    return ConfirmPage(bloc, phoneNumber);
  }

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => Duration.zero;
}

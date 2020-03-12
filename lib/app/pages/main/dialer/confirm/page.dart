import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../../data/repositories/call.dart';

import '../../../../resources/theme.dart';
import '../../../../widgets/transparent_status_bar.dart';
import 'controller.dart';

import '../../../../resources/localizations.dart';

class ConfirmPage extends View {
  final String destination;

  ConfirmPage(this.destination);

  @override
  State<StatefulWidget> createState() => ConfirmPageState(destination);
}

class ConfirmPageState extends ViewState<ConfirmPage, ConfirmController>
    with TickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _animation;

  ConfirmPageState(String destination)
      : super(ConfirmController(DataCallRepository(), destination));

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.decelerate,
    );

    controller.initAnimation(_animationController);
  }

  static const _style = TextStyle(
    fontSize: 16,
  );

  static const _largeStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  @override
  Widget buildPage() {
    return WillPopScope(
      key: globalKey,
      onWillPop: controller.onWillPop,
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
                        Text(
                          context.msg.main.dialer.confirm.title,
                          style: _largeStyle,
                        ),
                        SizedBox(height: 48),
                        Text(
                          context.msg.main.dialer.confirm.description.origin,
                          style: _style,
                        ),
                        SizedBox(height: 8),
                        Text('(+31) 50 1234567', style: _largeStyle),
                        SizedBox(height: 48),
                        Text(
                          context.msg.main.dialer.confirm.description.main,
                          style: _style,
                        ),
                        SizedBox(height: 48),
                        Text(
                          context.msg.main.dialer.confirm.description.action,
                          style: _style,
                        ),
                        SizedBox(height: 8),
                        Text(widget.destination, style: _largeStyle),
                      ],
                    ),
                  ),
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
  final String destination;

  ConfirmPageRoute({@required this.destination});

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
    return ConfirmPage(destination);
  }

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => Duration.zero;
}

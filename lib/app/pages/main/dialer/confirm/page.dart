import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:provider/provider.dart';

import '../../../../../domain/entities/brand.dart';

import '../../../../../domain/repositories/auth.dart';
import '../../../../../domain/repositories/call.dart';
import '../../../../../domain/repositories/setting.dart';
import '../../../../../domain/repositories/logging.dart';

import '../../../../widgets/transparent_status_bar.dart';
import 'controller.dart';

import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';

class ConfirmPage extends View {
  final CallRepository _callRepository;
  final SettingRepository _settingRepository;
  final LoggingRepository _loggingRepository;
  final AuthRepository _authRepository;

  final String destination;

  ConfirmPage(
    this._callRepository,
    this._settingRepository,
    this._loggingRepository,
    this._authRepository, {
    @required this.destination,
  });

  @override
  State<StatefulWidget> createState() => ConfirmPageState(
        _callRepository,
        _settingRepository,
        _loggingRepository,
        _authRepository,
        destination,
      );
}

class ConfirmPageState extends ViewState<ConfirmPage, ConfirmController>
    with TickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _animation;

  ConfirmPageState(
    CallRepository callRepository,
    SettingRepository settingRepository,
    LoggingRepository loggingRepository,
    AuthRepository authRepository,
    String destination,
  ) : super(ConfirmController(
          callRepository,
          settingRepository,
          loggingRepository,
          authRepository,
          destination,
        ));

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
    final appName = Provider.of<Brand>(context).appName;

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
                          context.msg.main.dialer.confirm.title(appName),
                          style: _largeStyle,
                        ),
                        SizedBox(height: 48),
                        Text(
                          context.msg.main.dialer.confirm.description.origin,
                          style: _style,
                        ),
                        SizedBox(height: 8),
                        Text(controller.outgoingCli, style: _largeStyle),
                        SizedBox(height: 48),
                        Text(
                          context.msg.main.dialer.confirm.description.main(
                            appName,
                          ),
                          style: _style,
                        ),
                        SizedBox(height: 48),
                        Text(
                          context.msg.main.dialer.confirm.description.action,
                          style: _style,
                        ),
                        SizedBox(height: 8),
                        Text(widget.destination, style: _largeStyle),
                        if (context.isAndroid)
                          Expanded(
                            child: _AndroidInputs(
                              checkboxValue: !controller.showConfirmPage,
                              onCheckboxValueChangd: (v) =>
                                  controller.setShowDialogSetting(!v),
                              onCallButtonPressed: controller.call,
                              onCancelButtonPressed: controller.pop,
                              destination: context
                                  .msg.main.dialer.confirm.button
                                  .call(widget.destination)
                                  .toUpperCase(),
                            ),
                          ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Don\'t show this again'),
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
  final String destination;

  ConfirmPageRoute({
    @required this.destination,
  });

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
    return ConfirmPage(
      Provider.of<CallRepository>(context),
      Provider.of<SettingRepository>(context),
      Provider.of<LoggingRepository>(context),
      Provider.of<AuthRepository>(context),
      destination: destination,
    );
  }

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => Duration.zero;
}

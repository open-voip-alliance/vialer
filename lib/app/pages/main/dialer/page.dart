import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../../resources/theme.dart';
import '../../../resources/localizations.dart';

import '../../../routes.dart';
import '../../../widgets/transparent_status_bar.dart';
import 'widgets/key_input.dart';
import 'widgets/keypad.dart';
import '../widgets/caller/state.dart';
import 'widgets/t9/widget.dart';
import '../widgets/conditional_placeholder.dart';
import '../../../widgets/stylized_button.dart';
import '../widgets/caller.dart';
import '../widgets/connectivity_alert.dart';
import '../../../widgets/connectivity_checker.dart';

import '../../../../domain/entities/brand.dart';

import '../../../util/conditional_capitalization.dart';

import 'cubit.dart';

class DialerPage extends StatefulWidget {
  final bool isInBottomNavBar;

  const DialerPage({
    Key key,
    @required this.isInBottomNavBar,
  }) : super(key: key);

  @override
  _DialerPageState createState() => _DialerPageState();
}

// ignore: prefer_mixin
class _DialerPageState extends State<DialerPage> with WidgetsBindingObserver {
  final _keypadController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      final callerState = context.read<CallerCubit>().state;

      // We pop the dialer on Android if we're initiating a call.
      if (Platform.isAndroid && callerState is InitiatingCall) {
        Navigator.of(context).popUntil(
          (route) => route.settings.name == Routes.main,
        );
      }
    }
  }

  void _onDialerStateChanged(BuildContext context, DialerState state) {
    if (state.lastCalledDestination != null && _keypadController.text.isEmpty) {
      _keypadController.text = state.lastCalledDestination;
    }
  }

  void _call(BuildContext context) {
    context.read<DialerCubit>().call(_keypadController.text);
    _keypadController.clear();
  }

  @override
  Widget build(BuildContext context) {
    var body = TransparentStatusBar(
      brightness: Brightness.dark,
      child: BlocProvider<DialerCubit>(
        create: (context) => DialerCubit(context.read<CallerCubit>()),
        child: BlocListener<DialerCubit, DialerState>(
          listener: _onDialerStateChanged,
          child: BlocBuilder<CallerCubit, CallerState>(
            builder: (context, state) {
              final callerCubit = context.watch<CallerCubit>();
              final dialerCubit = context.watch<DialerCubit>();
              final appName = Provider.of<Brand>(context).appName;

              return ConditionalPlaceholder(
                showPlaceholder: state is NoPermission,
                placeholder: Warning(
                  title: Text(context.msg.main.dialer.noPermission.title),
                  description: state is NoPermission && !state.dontAskAgain
                      ? Text(
                          context.msg.main.dialer.noPermission
                              .description(appName),
                        )
                      : Text(
                          context.msg.main.dialer.noPermission
                              .permanentDescription(appName),
                        ),
                  icon: Icon(VialerSans.missedCall),
                  children: state is NoPermission && !state.dontAskAgain
                      ? <Widget>[
                          SizedBox(height: 40),
                          StylizedButton.raised(
                            colored: true,
                            onPressed: callerCubit.requestPermission,
                            child: Text(
                              context.msg.main.dialer.noPermission.button
                                  .toUpperCaseIfAndroid(context),
                            ),
                          ),
                        ]
                      : <Widget>[],
                ),
                child: Column(
                  children: <Widget>[
                    if (context.isAndroid) ...[
                      SafeArea(
                        child:
                            T9ContactsListView(controller: _keypadController),
                      ),
                      Divider(
                        height: 1,
                        thickness: 1,
                      ),
                    ] else if (context.isIOS)
                      SafeArea(
                        child: SizedBox(
                          height: 95,
                        ),
                      ),
                    Material(
                      child: KeyInput(
                        controller: _keypadController,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: BlocBuilder<ConnectivityCheckerCubit,
                              ConnectivityState>(
                            builder: (context, state) {
                              return Keypad(
                                controller: _keypadController,
                                onCallButtonPressed: state is Connected
                                    ? () => _call(context)
                                    : null,
                                onDeleteButtonPressed: state is Connected
                                    ? dialerCubit.clearLastCalledDestination
                                    : null,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );

    return Scaffold(
      body: !widget.isInBottomNavBar
          ? ConnectivityAlert(
              child: body,
            )
          : body,
    );
  }

  @override
  void dispose() {
    super.dispose();

    WidgetsBinding.instance.removeObserver(this);
  }
}
